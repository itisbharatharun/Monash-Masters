import json
import boto3
import os
from urllib.parse import urlparse

s3 = boto3.client('s3')
MEDIA_BUCKET = os.environ['MEDIA_BUCKET']
EXPIRY = 3600  # 1 hour

CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
    'Access-Control-Allow-Methods': 'POST,OPTIONS',
}

def lambda_handler(event, context):
    if (event.get('httpMethod') or '').upper() == 'OPTIONS':
        return {'statusCode': 200, 'headers': CORS_HEADERS, 'body': ''}

    try:
        body = json.loads(event.get('body') or '{}')
        urls = body.get('urls')

        if not urls or not isinstance(urls, list):
            return {
                'statusCode': 400,
                'headers': CORS_HEADERS,
                'body': json.dumps({'error': 'urls must be a non-empty list'})
            }

        signed = {}
        for url in urls:
            # Accept either full S3 URL or just a key
            if url.startswith('https://'):
                parsed = urlparse(url)
                key = parsed.path.lstrip('/')
            else:
                key = url

            try:
                presigned = s3.generate_presigned_url(
                    'get_object',
                    Params={'Bucket': MEDIA_BUCKET, 'Key': key},
                    ExpiresIn=EXPIRY
                )
                signed[url] = presigned
            except Exception as e:
                signed[url] = None
                print(f"Failed to sign {key}: {e}")

        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps({'signed_urls': signed})
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps({'error': str(e)})
        }
