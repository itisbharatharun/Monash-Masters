import json
import boto3
import os
import tempfile
import base64
import uuid
from pathlib import Path

dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')
s3 = boto3.client('s3')

TABLE_NAME = os.environ['DYNAMODB_TABLE']
INFERENCE_FUNCTION_NAME = os.environ['INFERENCE_FUNCTION_NAME']
MEDIA_BUCKET = os.environ['MEDIA_BUCKET']

table = dynamodb.Table(TABLE_NAME)


def spec_url(item):
    """
    Spec section 4.3: return thumbnail URL for images, full URL for videos.
    This is what gets shown in query results and previewed in the UI.
    """
    if item.get('file_type') == 'image' and item.get('thumbnail_url'):
        return item['thumbnail_url']
    return item.get('file_url_final') or item['file_url']


def get_item_by_url(url):
    """
    Look up a DynamoDB record by URL.
    Tries file_url (partition key) first. Falls back to scanning file_url_final.
    """
    response = table.get_item(Key={'file_url': url})
    item = response.get('Item')
    if item:
        return item

    response = table.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('file_url_final').eq(url)
    )
    items = response.get('Items', [])
    return items[0] if items else None


def scan_complete_items():
    """Full paginated scan of all complete records."""
    response = table.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('status').eq('complete')
    )
    items = response.get('Items', [])
    while 'LastEvaluatedKey' in response:
        response = table.scan(
            FilterExpression=boto3.dynamodb.conditions.Attr('status').eq('complete'),
            ExclusiveStartKey=response['LastEvaluatedKey']
        )
        items.extend(response.get('Items', []))
    return items


def query_by_tags(tags_with_counts):
    """
    Find files where every requested tag meets its minimum count (logical AND).
    Spec section 4.3: AND operation, not OR. Returns spec-correct URLs.
    """
    items = scan_complete_items()
    results = []
    for item in items:
        item_tags = item.get('tags', {})
        match = all(
            item_tags.get(tag, 0) >= min_count
            for tag, min_count in tags_with_counts.items()
        )
        if match:
            results.append({
                'url': spec_url(item),
                'file_url': item.get('file_url_final') or item['file_url'],
                'thumbnail_url': item.get('thumbnail_url', ''),
                'file_type': item.get('file_type', 'image')
            })
    return results


def query_by_species(species_name):
    """Find all files containing at least 1 of the requested species."""
    return query_by_tags({species_name: 1})


def query_by_thumbnail_url(thumbnail_url):
    """Given a thumbnail URL, return the full-size image URL."""
    response = table.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('thumbnail_url').eq(thumbnail_url)
    )
    items = response.get('Items', [])
    if not items:
        return None
    item = items[0]
    return item.get('file_url_final') or item['file_url']


def query_by_file(file_content, file_extension, bucket):
    """
    Run inference on uploaded query file, find DB files with matching tags.
    Spec section 4.3: query file must NOT be permanently stored.
    UUID in filename prevents concurrent request collisions.
    """
    detected_tags = {}
    with tempfile.TemporaryDirectory() as tmp_dir:
        # UUID ensures concurrent calls don't stomp on each other
        tmp_filename = f"query_{uuid.uuid4().hex}{file_extension}"
        tmp_path = os.path.join(tmp_dir, tmp_filename)

        with open(tmp_path, 'wb') as f:
            f.write(file_content)

        tmp_s3_key = f"tmp_query/{tmp_filename}"
        s3.upload_file(tmp_path, bucket, tmp_s3_key)
        print(f"Uploaded query file temporarily: s3://{bucket}/{tmp_s3_key}")

        try:
            response = lambda_client.invoke(
                FunctionName=INFERENCE_FUNCTION_NAME,
                InvocationType='RequestResponse',
                Payload=json.dumps({
                    'bucket': bucket,
                    'key': tmp_s3_key,
                    'file_url': f"https://{bucket}.s3.amazonaws.com/{tmp_s3_key}",
                    'checksum': 'query_temp',
                    'query_mode': True
                })
            )
            payload = json.loads(response['Payload'].read())
            body = json.loads(payload.get('body', '{}'))
            detected_tags = body.get('tags', {})
            print(f"Query file tags detected: {detected_tags}")
        finally:
            s3.delete_object(Bucket=bucket, Key=tmp_s3_key)
            print(f"Deleted temp query file: {tmp_s3_key}")

    if not detected_tags:
        return []

    results = query_by_tags({tag: 1 for tag in detected_tags.keys()})
    return [r['url'] for r in results]


def lambda_handler(event, context):
    cors_headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
    }

    try:
        body = json.loads(event.get('body', '{}'))
        query_type = body.get('query_type')

        if not query_type:
            return {'statusCode': 400, 'headers': cors_headers,
                    'body': json.dumps({'error': 'query_type is required'})}

        if query_type == 'tags':
            tags = body.get('tags')
            if not tags or not isinstance(tags, dict):
                return {'statusCode': 400, 'headers': cors_headers,
                        'body': json.dumps({'error': 'tags must be a non-empty dict e.g. {"wombat": 2}'})}
            results = query_by_tags(tags)
            return {'statusCode': 200, 'headers': cors_headers,
                    'body': json.dumps({'results': results, 'count': len(results)})}

        elif query_type == 'species':
            species = body.get('species')
            if not species:
                return {'statusCode': 400, 'headers': cors_headers,
                        'body': json.dumps({'error': 'species is required'})}
            results = query_by_species(species)
            return {'statusCode': 200, 'headers': cors_headers,
                    'body': json.dumps({'results': results, 'count': len(results)})}

        elif query_type == 'thumbnail_url':
            thumbnail_url = body.get('thumbnail_url')
            if not thumbnail_url:
                return {'statusCode': 400, 'headers': cors_headers,
                        'body': json.dumps({'error': 'thumbnail_url is required'})}
            full_url = query_by_thumbnail_url(thumbnail_url)
            if not full_url:
                return {'statusCode': 404, 'headers': cors_headers,
                        'body': json.dumps({'error': 'No file found for given thumbnail URL'})}
            return {'statusCode': 200, 'headers': cors_headers,
                    'body': json.dumps({'file_url': full_url})}

        elif query_type == 'file':
            file_content_b64 = body.get('file_content')
            file_extension = body.get('file_extension', '.jpg')
            if not file_content_b64:
                return {'statusCode': 400, 'headers': cors_headers,
                        'body': json.dumps({'error': 'file_content (base64) is required'})}
            file_content = base64.b64decode(file_content_b64)
            results = query_by_file(file_content, file_extension, MEDIA_BUCKET)
            return {'statusCode': 200, 'headers': cors_headers,
                    'body': json.dumps({'results': results, 'count': len(results)})}

        else:
            return {'statusCode': 400, 'headers': cors_headers,
                    'body': json.dumps({'error': f"Unknown query_type: {query_type}"})}

    except Exception as e:
        print(f"Error: {str(e)}")
        return {'statusCode': 500, 'headers': cors_headers,
                'body': json.dumps({'error': str(e)})}
