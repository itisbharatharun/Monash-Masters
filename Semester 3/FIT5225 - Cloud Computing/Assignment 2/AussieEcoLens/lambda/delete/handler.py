import json
import boto3
import os
from pathlib import Path
from urllib.parse import urlparse

# AWS clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Environment variables
TABLE_NAME = os.environ['DYNAMODB_TABLE']
MEDIA_BUCKET = os.environ['MEDIA_BUCKET']

table = dynamodb.Table(TABLE_NAME)


def get_s3_key_from_url(url):
    """Extract S3 key from a full S3 URL."""
    parsed = urlparse(url)
    return parsed.path.lstrip('/')


def get_item_by_url(url):
    """
    Look up a DynamoDB record by URL.
    First tries file_url (partition key — fast).
    Falls back to scanning file_url_final if not found.
    """
    response = table.get_item(Key={'file_url': url})
    item = response.get('Item')
    if item:
        return item

    # Fallback — url may be file_url_final (post-move URL)
    response = table.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('file_url_final').eq(url)
    )
    items = response.get('Items', [])
    return items[0] if items else None


def delete_file(file_url):
    """
    Delete a file and its thumbnail from S3 and remove its DynamoDB record.
    Accepts both file_url and file_url_final.
    Thumbnails are deleted for both images and videos — videos now have thumbnails
    generated from the best detection frame (added June 2026).
    Returns (success, message).
    """
    item = get_item_by_url(file_url)

    if not item:
        return False, f"File not found in database: {file_url}"

    thumbnail_url = item.get('thumbnail_url', '')

    # Delete the actual file — use file_url_final if available, otherwise file_url
    actual_url = item.get('file_url_final') or item['file_url']
    file_key = get_s3_key_from_url(actual_url)
    try:
        s3.delete_object(Bucket=MEDIA_BUCKET, Key=file_key)
        print(f"Deleted file from S3: {file_key}")
    except Exception as e:
        print(f"Warning: Could not delete file {file_key}: {str(e)}")

    # Delete thumbnail from S3 if it exists — applies to both images and videos.
    # Videos have thumbnails generated from their best detection frame.
    if thumbnail_url:
        thumbnail_key = get_s3_key_from_url(thumbnail_url)
        try:
            s3.delete_object(Bucket=MEDIA_BUCKET, Key=thumbnail_key)
            print(f"Deleted thumbnail from S3: {thumbnail_key}")
        except Exception as e:
            print(f"Warning: Could not delete thumbnail {thumbnail_key}: {str(e)}")

    # Delete DynamoDB record — always keyed by original file_url
    table.delete_item(Key={'file_url': item['file_url']})
    print(f"Deleted DynamoDB record for: {item['file_url']}")

    return True, f"Successfully deleted: {file_url}"


def lambda_handler(event, context):
    """
    Accepts a list of file URLs and deletes each file, its thumbnail,
    and its DynamoDB record. Accepts both file_url and file_url_final.
    Expected request body:
    {
        "urls": ["https://...", "https://..."]
    }
    """
    cors_headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
    }

    try:
        body = json.loads(event.get('body', '{}'))
        urls = body.get('urls')

        if not urls or not isinstance(urls, list):
            return {
                'statusCode': 400,
                'headers': cors_headers,
                'body': json.dumps({'error': 'urls must be a non-empty list'})
            }

        deleted = []
        errors = {}

        for file_url in urls:
            success, message = delete_file(file_url)
            if success:
                deleted.append(file_url)
            else:
                errors[file_url] = message

        response_body = {
            'message': 'Bulk delete complete',
            'deleted': deleted,
            'count': len(deleted)
        }

        if errors:
            response_body['errors'] = errors

        return {
            'statusCode': 200,
            'headers': cors_headers,
            'body': json.dumps(response_body)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': cors_headers,
            'body': json.dumps({'error': str(e)})
        }
