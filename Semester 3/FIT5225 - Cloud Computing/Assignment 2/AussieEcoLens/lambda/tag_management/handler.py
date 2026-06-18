import json
import boto3
import os

# AWS clients
dynamodb = boto3.resource('dynamodb')

# Environment variables
TABLE_NAME = os.environ['DYNAMODB_TABLE']

table = dynamodb.Table(TABLE_NAME)


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


def add_tags(file_url, tags_to_add):
    """
    Add tags for a file in DynamoDB.
    Each tag gets count of 1 if not present, incremented by 1 if already exists.
    Accepts both file_url and file_url_final.
    """
    item = get_item_by_url(file_url)

    if not item:
        return False, f"File not found: {file_url}"

    current_tags = item.get('tags', {})

    for tag in tags_to_add:
        current_tags[tag] = int(current_tags.get(tag, 0)) + 1

    # Always update using the original partition key
    table.update_item(
        Key={'file_url': item['file_url']},
        UpdateExpression='SET tags = :tags',
        ExpressionAttributeValues={':tags': current_tags}
    )

    print(f"Tags added for {item['file_url']}: {tags_to_add}")
    return True, current_tags


def remove_tags(file_url, tags_to_remove):
    """
    Remove tags from a file in DynamoDB.
    If a tag is not present, it is silently ignored (per spec).
    Accepts both file_url and file_url_final.
    """
    item = get_item_by_url(file_url)

    if not item:
        return False, f"File not found: {file_url}"

    current_tags = item.get('tags', {})

    for tag in tags_to_remove:
        if tag in current_tags:
            del current_tags[tag]

    # Always update using the original partition key
    table.update_item(
        Key={'file_url': item['file_url']},
        UpdateExpression='SET tags = :tags',
        ExpressionAttributeValues={':tags': current_tags}
    )

    print(f"Tags removed for {item['file_url']}: {tags_to_remove}")
    return True, current_tags


def lambda_handler(event, context):
    """
    Handles bulk tag addition and removal across multiple file URLs.
    Accepts both file_url and file_url_final in the urls list.
    Expected request body:
    {
        "urls": ["https://...", "https://..."],
        "tags": ["Vombatus_ursinus", "Macropus_giganteus"],
        "operation": 1   (1 = add, 0 = remove)
    }
    """
    try:
        body = json.loads(event.get('body', '{}'))

        urls = body.get('urls')
        tags = body.get('tags')
        operation = body.get('operation')

        if not urls or not isinstance(urls, list):
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
                },
                'body': json.dumps({'error': 'urls must be a non-empty list'})
            }

        if not tags or not isinstance(tags, list):
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
                },
                'body': json.dumps({'error': 'tags must be a non-empty list'})
            }

        if operation not in [0, 1]:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
                },
                'body': json.dumps({'error': 'operation must be 1 (add) or 0 (remove)'})
            }

        results = {}
        errors = {}

        for file_url in urls:
            if operation == 1:
                success, result = add_tags(file_url, tags)
            else:
                success, result = remove_tags(file_url, tags)

            if success:
                results[file_url] = result
            else:
                errors[file_url] = result

        response_body = {
            'message': 'Bulk tag operation complete',
            'operation': 'add' if operation == 1 else 'remove',
            'updated': results,
            'count': len(results)
        }

        if errors:
            response_body['errors'] = errors

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
            },
            'body': json.dumps(response_body)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
            },
            'body': json.dumps({'error': str(e)})
        }
