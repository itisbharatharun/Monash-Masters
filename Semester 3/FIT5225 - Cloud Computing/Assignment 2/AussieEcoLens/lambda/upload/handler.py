import json
import boto3
import os
import uuid
import logging
from pathlib import Path

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

MEDIA_BUCKET = os.environ['MEDIA_BUCKET']
UPLOAD_PREFIX = 'uploads/'
PRESIGN_EXPIRY_SECONDS = 300

ALLOWED_EXTENSIONS = {
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp',
    '.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm',
}

CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
    'Access-Control-Allow-Methods': 'POST,OPTIONS',
}


def _response(status_code, body_dict):
    return {
        'statusCode': status_code,
        'headers': CORS_HEADERS,
        'body': json.dumps(body_dict),
    }


def lambda_handler(event, context):
    """
    Issues a short-lived S3 presigned PUT URL so the browser can upload a media
    file directly to S3 under the uploads/ prefix, bypassing API Gateway's 10MB
    payload limit.

    Expected request body:
        {"filename": "photo.jpg", "content_type": "image/jpeg"}

    Success response:
        {"upload_url": "...", "file_key": "uploads/<uuid>.jpg",
         "file_url": "https://<bucket>.s3.amazonaws.com/uploads/<uuid>.jpg"}
    """
    http_method = (event.get('httpMethod') or '').upper()
    if http_method == 'OPTIONS':
        return _response(200, {'message': 'CORS preflight OK'})

    try:
        body = json.loads(event.get('body') or '{}')
    except (ValueError, TypeError):
        return _response(400, {'error': 'Request body must be valid JSON'})

    filename = body.get('filename')
    if not filename or not isinstance(filename, str):
        return _response(400, {'error': 'filename is required and must be a string'})

    ext = Path(filename).suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        return _response(400, {
            'error': f'File type "{ext or "<none>"}" not supported',
            'allowed': sorted(ALLOWED_EXTENSIONS),
        })

    content_type = body.get('content_type', 'application/octet-stream')
    if not isinstance(content_type, str):
        content_type = 'application/octet-stream'

    unique_key = f"{UPLOAD_PREFIX}{uuid.uuid4().hex}{ext}"

    try:
        upload_url = s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': MEDIA_BUCKET,
                'Key': unique_key,
                'ContentType': content_type,
            },
            ExpiresIn=PRESIGN_EXPIRY_SECONDS,
        )
    except Exception as e:
        logger.error(f"Failed to generate presigned URL for {unique_key}: {e}")
        return _response(500, {'error': 'Could not generate upload URL'})

    file_url = f"https://{MEDIA_BUCKET}.s3.amazonaws.com/{unique_key}"
    logger.info(f"Issued presigned PUT for {unique_key} (ct={content_type})")

    return _response(200, {
        'upload_url': upload_url,
        'file_key': unique_key,
        'file_url': file_url,
    })
