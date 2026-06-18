import json
import boto3
import os
import tempfile
from pathlib import Path
from PIL import Image

s3 = boto3.client('s3')

THUMBNAIL_MAX_WIDTH = int(os.environ.get('THUMBNAIL_MAX_WIDTH', '400'))
THUMBNAIL_MAX_HEIGHT = int(os.environ.get('THUMBNAIL_MAX_HEIGHT', '400'))
THUMBNAIL_QUALITY = int(os.environ.get('THUMBNAIL_QUALITY', '85'))


def generate_thumbnail(input_path, output_path, max_width, max_height, quality):
    """
    Resize image to fit within max_width x max_height preserving aspect ratio.
    Only downscales — never upscales. Saves as JPEG.
    """
    try:
        img = Image.open(input_path).convert('RGB')
    except Exception as e:
        print(f"Warning: Could not read image at {input_path}: {e}")
        return False

    original_w, original_h = img.size
    scale = min(max_width / original_w, max_height / original_h)

    if scale < 1.0:
        new_w = int(original_w * scale)
        new_h = int(original_h * scale)
        resized = img.resize((new_w, new_h), Image.LANCZOS)
    else:
        resized = img

    resized.save(output_path, 'JPEG', quality=quality)
    print(f"Thumbnail saved: {output_path} ({resized.size[0]}x{resized.size[1]})")
    return True


def lambda_handler(event, context):
    bucket = event['bucket']
    key = event['key']
    file_url = event['file_url']
    delete_source = event.get('delete_source', False)

    thumbnail_key = event.get('thumbnail_key')
    if not thumbnail_key:
        relative = key[len('media/'):] if key.startswith('media/') else key
        thumbnail_key = f"thumbnails/{Path(relative).with_suffix('.jpg')}"

    print(f"Generating thumbnail for: s3://{bucket}/{key}")
    print(f"Thumbnail destination: s3://{bucket}/{thumbnail_key}")

    with tempfile.TemporaryDirectory() as tmp_dir:
        original_filename = Path(key).name
        local_input = os.path.join(tmp_dir, original_filename)
        s3.download_file(bucket, key, local_input)

        thumbnail_filename = Path(thumbnail_key).name
        local_output = os.path.join(tmp_dir, thumbnail_filename)

        success = generate_thumbnail(
            local_input,
            local_output,
            THUMBNAIL_MAX_WIDTH,
            THUMBNAIL_MAX_HEIGHT,
            THUMBNAIL_QUALITY
        )

        if not success:
            # Clean up temp frame even on failure
            if delete_source:
                try:
                    s3.delete_object(Bucket=bucket, Key=key)
                    print(f"Deleted temp source after failed thumbnail: {key}")
                except Exception as e:
                    print(f"Warning: Could not delete temp source {key}: {e}")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Thumbnail skipped — image could not be read', 'key': key})
            }

        s3.upload_file(
            local_output,
            bucket,
            thumbnail_key,
            ExtraArgs={'ContentType': 'image/jpeg'}
        )

        thumbnail_url = f"https://{bucket}.s3.amazonaws.com/{thumbnail_key}"
        print(f"Thumbnail uploaded to: {thumbnail_url}")

        # Delete the temporary source frame if this was a video thumbnail.
        # The frame lives at tmp_frames/ and is not needed after thumbnail generation.
        if delete_source:
            try:
                s3.delete_object(Bucket=bucket, Key=key)
                print(f"Deleted temp source frame: {key}")
            except Exception as e:
                print(f"Warning: Could not delete temp source {key}: {e}")

    return {
        'statusCode': 200,
        'body': json.dumps({'message': f"Thumbnail created at {thumbnail_url}"})
    }
