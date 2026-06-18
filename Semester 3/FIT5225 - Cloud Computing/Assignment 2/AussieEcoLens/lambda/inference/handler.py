import json
import boto3
import os
import tempfile
from pathlib import Path
from collections import Counter

import torch
import torchvision.transforms as transforms
from PIL import Image
import numpy as np
import cv2

from megadetector.detection import run_detector_batch

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')
sns = boto3.client('sns')

TABLE_NAME = os.environ['DYNAMODB_TABLE']
MODELS_BUCKET = os.environ['MODELS_BUCKET']
MEGADETECTOR_KEY = os.environ.get('MEGADETECTOR_KEY', 'mdv5a.pt')
SPECIESNET_KEY = os.environ.get('SPECIESNET_KEY', 'model.pt')
LABELS_KEY = os.environ.get('LABELS_KEY', 'labels.txt')
THUMBNAIL_FUNCTION_NAME = os.environ['THUMBNAIL_FUNCTION_NAME']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

LOWER_CONF = float(os.environ.get('LOWER_CONF', '0.05'))
SNIP_SIZE = int(os.environ.get('SNIP_SIZE', '600'))
DEVICE = 'cpu'

table = dynamodb.Table(TABLE_NAME)

# Global cache — persists across warm invocations
_megadetector_path = None
_speciesnet_model = None
_classes = None
_common_names = None

transform = transforms.Compose([
    transforms.Resize((480, 480)),
    transforms.ToTensor(),
])

# Explicit fallback tags for labels.txt rows with missing/ambiguous common names.
# Keyed by model class name. Keeps the tag vocabulary clean (e.g. avoids the
# bare-genus row "rattus;;" producing tag "rattus" alongside real species' "rat").
COMMON_NAME_FALLBACKS = {
    "Rattus": "rat",  # labels.txt row "...;rattus;;" has an empty common-name field
}


def load_classes():
    """
    Load class names from labels.txt in S3.
    Returns:
        model_classes: list of 'Genus_species' strings used to index SpeciesNet output
        common_names:  dict mapping model class -> last word of common name (spec tag format)
    """
    global _classes, _common_names
    if _classes is not None and _common_names is not None:
        return _classes, _common_names

    labels_path = '/tmp/labels.txt'
    print(f"Downloading labels from s3://{MODELS_BUCKET}/{LABELS_KEY}")
    s3.download_file(MODELS_BUCKET, LABELS_KEY, labels_path)

    model_classes = []
    common_names = {}
    with open(labels_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split(';')
            if len(parts) < 7:
                continue
            genus = parts[4].capitalize()
            species = parts[5].strip()
            common_full = parts[6].strip().lower()
            class_name = f"{genus}_{species}" if species else genus
            model_classes.append(class_name)

            if class_name in COMMON_NAME_FALLBACKS:
                tag = COMMON_NAME_FALLBACKS[class_name]
            elif common_full:
                tag = common_full.split()[-1]
            else:
                tag = class_name.lower()
            common_names[class_name] = tag

    _classes = model_classes
    _common_names = common_names
    print(f"Loaded {len(model_classes)} classes")
    return _classes, _common_names


def download_models():
    """Download model weights from S3 to /tmp. Cached across warm invocations."""
    global _megadetector_path, _speciesnet_model

    md_path = '/tmp/mdv5a.pt'
    sn_path = '/tmp/model.pt'

    if _megadetector_path is None or not os.path.exists(md_path):
        print(f"Downloading MegaDetector from s3://{MODELS_BUCKET}/{MEGADETECTOR_KEY}")
        s3.download_file(MODELS_BUCKET, MEGADETECTOR_KEY, md_path)
        _megadetector_path = md_path

    if _speciesnet_model is None:
        print(f"Downloading SpeciesNet from s3://{MODELS_BUCKET}/{SPECIESNET_KEY}")
        s3.download_file(MODELS_BUCKET, SPECIESNET_KEY, sn_path)
        _speciesnet_model = torch.load(sn_path, map_location=DEVICE, weights_only=False)
        _speciesnet_model.eval()
        _speciesnet_model.to(DEVICE)

    return _megadetector_path, _speciesnet_model


def extract_frames_from_video(video_path, output_dir):
    """
    Extract exactly 1 frame per second using millisecond timestamp seeking.
    Spec section 4.2: "extract 1 image per second (do not try to extract all frames)".
    """
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise RuntimeError(f"Cannot open video: {video_path}")

    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    if fps <= 0 or fps != fps:  # guard against NaN / missing metadata
        cap.release()
        raise ValueError(f"Invalid FPS metadata: {fps}")

    duration_seconds = max(int(total_frames / fps), 1)
    frame_paths = []

    for second in range(duration_seconds):
        cap.set(cv2.CAP_PROP_POS_MSEC, second * 1000)
        ret, frame = cap.read()
        if not ret:
            break
        frame_path = os.path.join(output_dir, f"frame_{second:04d}.jpg")
        cv2.imwrite(frame_path, frame)
        frame_paths.append(frame_path)

    cap.release()
    print(f"Extracted {len(frame_paths)} frames (duration: {duration_seconds}s)")
    return frame_paths


def pick_best_frame(detections, frame_paths):
    """
    Return the frame path with the highest max_detection_conf from MegaDetector.
    Falls back to frame_paths[0] if no detections were found in any frame.

    detections: list of MegaDetector result dicts, one per image, in the same
                order as frame_paths.
    """
    best_path = frame_paths[0]
    best_conf = -1.0

    for entry in detections:
        img_path = entry.get('file', '')
        conf = float(entry.get('max_detection_conf', 0.0))
        if conf > best_conf and Path(img_path).exists():
            best_conf = conf
            best_path = img_path

    print(f"Best frame for thumbnail: {best_path} (conf={best_conf:.4f})")
    return best_path


def crop_detections(detections, snip_size, conf_thresh, output_dir):
    """Crop detected animals from images. Returns list of cropped image paths."""
    cropped_paths = []
    for entry in detections:
        img_path = entry['file']
        if not Path(img_path).exists():
            continue
        img = Image.open(img_path).convert('RGB')
        W, H = img.size
        crop_num = 0
        for detection in entry.get('detections', []):
            if detection['category'] != '1':
                continue
            if detection['conf'] < conf_thresh:
                continue
            x, y, w, h = detection['bbox']
            left = int(x * W)
            top = int(y * H)
            right = int((x + w) * W)
            bottom = int((y + h) * H)
            crop = img.crop((left, top, right, bottom))
            resized = crop.resize((snip_size, snip_size), Image.BILINEAR)
            out_path = os.path.join(output_dir, f"{Path(img_path).stem}-{crop_num}.jpg")
            resized.save(out_path)
            cropped_paths.append(out_path)
            crop_num += 1
    return cropped_paths


@torch.no_grad()
def classify_crop(image_path, model, model_classes):
    """Run SpeciesNet on a single cropped image. Returns (model_class, confidence)."""
    img = Image.open(image_path).convert('RGB')
    img = transform(img).unsqueeze(0).permute(0, 2, 3, 1).to(DEVICE)
    logits = model(img)
    probs = torch.softmax(logits, dim=1)[0].cpu().numpy()
    best_idx = int(np.argmax(probs))
    return model_classes[best_idx], float(probs[best_idx])


def run_inference_on_images(image_paths, md_model_path, sn_model, model_classes, common_names, tmp_dir):
    """
    Full pipeline: MegaDetector -> crop -> SpeciesNet.
    Returns:
        species_counts: Counter keyed by common name tag
        detections:     raw MegaDetector output (used by caller to pick best thumbnail frame)
    """
    if not image_paths:
        return Counter(), []

    crops_dir = os.path.join(tmp_dir, 'crops')
    os.makedirs(crops_dir, exist_ok=True)

    detections = run_detector_batch.load_and_run_detector_batch(
        image_file_names=image_paths,
        model_file=md_model_path
    )
    cropped_paths = crop_detections(detections, SNIP_SIZE, LOWER_CONF, crops_dir)

    species_counts = Counter()
    for crop_path in cropped_paths:
        model_class, confidence = classify_crop(crop_path, sn_model, model_classes)
        tag = common_names.get(model_class, model_class.lower())
        print(f"Detected: {tag} (model_class={model_class}, conf={confidence:.4f})")
        species_counts[tag] += 1

    return species_counts, detections


def move_file_to_species_folder(bucket, original_key, species_counts):
    """
    Move uploaded file to media/{dominant_tag}/ prefix.
    """
    filename = Path(original_key).name
    dominant = species_counts.most_common(1)[0][0] if species_counts else 'unknown'
    safe_dominant = dominant.replace(' ', '-')
    new_key = f"media/{safe_dominant}/{filename}"

    s3.copy_object(
        Bucket=bucket,
        CopySource={'Bucket': bucket, 'Key': original_key},
        Key=new_key
    )
    print(f"Copied to s3://{bucket}/{new_key}")

    s3.delete_object(Bucket=bucket, Key=original_key)
    print(f"Deleted original s3://{bucket}/{original_key}")

    return new_key, f"https://{bucket}.s3.amazonaws.com/{new_key}"


def publish_sns_notifications(species_counts, file_url):
    """
    One SNS message per detected tag with MessageAttributes for filter policies.
    """
    for tag, count in species_counts.items():
        message = json.dumps({
            'species': tag,
            'count': count,
            'file_url': file_url,
            'message': f"New file uploaded containing {tag} (count: {count})"
        })
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"AussieEcoLens: {tag} detected",
            Message=message,
            MessageAttributes={
                'species': {'DataType': 'String', 'StringValue': tag}
            }
        )
        print(f"SNS notification published for {tag}")


def is_video(key):
    return Path(key).suffix.lower() in {'.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm'}


def lambda_handler(event, context):
    """
    Receives event from deduplication Lambda or query Lambda.
    query_mode=True: run inference only, skip DB write / SNS / file move.
    """
    bucket = event['bucket']
    key = event['key']
    file_url = event['file_url']
    checksum = event.get('checksum', '')
    query_mode = event.get('query_mode', False)

    print(f"Running inference on: s3://{bucket}/{key} | query_mode={query_mode}")

    model_classes, common_names = load_classes()
    md_model_path, sn_model = download_models()

    with tempfile.TemporaryDirectory() as tmp_dir:
        local_file = os.path.join(tmp_dir, Path(key).name)
        s3.download_file(bucket, key, local_file)

        file_type = 'video' if is_video(key) else 'image'

        if file_type == 'video':
            frames_dir = os.path.join(tmp_dir, 'frames')
            os.makedirs(frames_dir, exist_ok=True)
            image_paths = extract_frames_from_video(local_file, frames_dir)
        else:
            image_paths = [local_file]

        species_counts, detections = run_inference_on_images(
            image_paths, md_model_path, sn_model, model_classes, common_names, tmp_dir
        )
        tags = dict(species_counts)
        print(f"Tags: {tags}")

        if query_mode:
            print("Query mode: skipping DB write, SNS, and file move.")
            return {
                'statusCode': 200,
                'body': json.dumps({'tags': tags})
            }

        new_key, new_file_url = move_file_to_species_folder(bucket, key, species_counts)

        # Derive thumbnail key — same pattern for both images and videos.
        # For videos, the thumbnail is generated from the best detected frame.
        relative = new_key[len('media/'):] if new_key.startswith('media/') else new_key
        thumbnail_key = f"thumbnails/{Path(relative).with_suffix('.jpg')}"
        thumbnail_url = f"https://{bucket}.s3.amazonaws.com/{thumbnail_key}"

        table.update_item(
            Key={'file_url': file_url},
            UpdateExpression='SET tags = :tags, file_type = :file_type, thumbnail_url = :thumbnail_url, #st = :status, file_url_final = :final_url',
            ExpressionAttributeValues={
                ':tags': tags,
                ':file_type': file_type,
                ':thumbnail_url': thumbnail_url,
                ':status': 'complete',
                ':final_url': new_file_url
            },
            ExpressionAttributeNames={'#st': 'status'}
        )
        print(f"DynamoDB updated: {file_url} -> {new_file_url}")

        if file_type == 'image':
            # Images: thumbnail Lambda downloads the media file directly from S3
            lambda_client.invoke(
                FunctionName=THUMBNAIL_FUNCTION_NAME,
                InvocationType='Event',
                Payload=json.dumps({
                    'bucket': bucket,
                    'key': new_key,
                    'thumbnail_key': thumbnail_key,
                    'file_url': new_file_url
                })
            )
            print("Thumbnail Lambda invoked for image.")

        elif file_type == 'video' and image_paths:
            # Videos: pick the frame with the highest detection confidence,
            # upload it temporarily to S3, then invoke the thumbnail Lambda.
            # The temp frame is deleted after thumbnail Lambda picks it up.
            best_frame_path = pick_best_frame(detections, image_paths)
            temp_frame_key = f"tmp_frames/{Path(key).stem}_thumb.jpg"

            s3.upload_file(best_frame_path, bucket, temp_frame_key)
            print(f"Uploaded best frame to s3://{bucket}/{temp_frame_key}")

            lambda_client.invoke(
                FunctionName=THUMBNAIL_FUNCTION_NAME,
                InvocationType='Event',
                Payload=json.dumps({
                    'bucket': bucket,
                    'key': temp_frame_key,
                    'thumbnail_key': thumbnail_key,
                    'file_url': new_file_url,
                    'delete_source': True   # signal thumbnail Lambda to delete temp frame after use
                })
            )
            print("Thumbnail Lambda invoked for video.")

        if tags:
            publish_sns_notifications(species_counts, new_file_url)

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Inference complete', 'tags': tags, 'file_url': new_file_url})
    }
