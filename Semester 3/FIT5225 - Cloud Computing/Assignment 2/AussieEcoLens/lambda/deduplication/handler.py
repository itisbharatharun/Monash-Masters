import json
import boto3
import hashlib
import os
import urllib.parse

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)


def compute_checksum(bucket, key):
    """Download file from S3 and compute MD5 checksum."""
    response = s3.get_object(Bucket=bucket, Key=key)
    file_content = response['Body'].read()
    return hashlib.md5(file_content).hexdigest()


def checksum_exists(checksum):
    """
    Scan DynamoDB with pagination to check if a file with this checksum already exists.
    Returns the matching item if found, None otherwise.
    """
    filter_expression = boto3.dynamodb.conditions.Attr('checksum').eq(checksum)

    response = table.scan(FilterExpression=filter_expression)
    items = response.get('Items', [])

    if items:
        return items[0]

    while 'LastEvaluatedKey' in response:
        response = table.scan(
            FilterExpression=filter_expression,
            ExclusiveStartKey=response['LastEvaluatedKey']
        )
        items = response.get('Items', [])
        if items:
            return items[0]

    return None


def lambda_handler(event, context):
    """
    Triggered by S3 upload event.
    Computes MD5 checksum of the uploaded file.
    If a duplicate exists in DynamoDB, deletes the file from S3 and returns 409.
    If not a duplicate, writes an initial DynamoDB record and invokes the inference Lambda.
    """
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(record['s3']['object']['key'])

    print(f"Processing file: s3://{bucket}/{key}")

    checksum = compute_checksum(bucket, key)
    print(f"Computed checksum: {checksum}")

    existing = checksum_exists(checksum)

    if existing:
        print(f"Duplicate detected. Deleting s3://{bucket}/{key}")
        s3.delete_object(Bucket=bucket, Key=key)
        return {
            'statusCode': 409,
            'body': json.dumps({
                'message': 'Duplicate file. Upload rejected.',
                'checksum': checksum,
                'existing_url': existing.get('file_url', '')
            })
        }

    file_url = f"https://{bucket}.s3.amazonaws.com/{key}"

    table.put_item(Item={
        'file_url': file_url,
        'checksum': checksum,
        'bucket': bucket,
        'key': key,
        'status': 'processing'
    })

    print(f"New file accepted. Stored initial record for: {file_url}")

    lambda_client = boto3.client('lambda')
    lambda_client.invoke(
        FunctionName=os.environ['INFERENCE_FUNCTION_NAME'],
        InvocationType='Event',
        Payload=json.dumps({
            'bucket': bucket,
            'key': key,
            'file_url': file_url,
            'checksum': checksum
        })
    )

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'File accepted for processing.',
            'file_url': file_url
        })
    }
