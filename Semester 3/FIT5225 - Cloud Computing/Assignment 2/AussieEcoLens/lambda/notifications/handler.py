import json
import boto3
import os

sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']


def lambda_handler(event, context):
    """
    Manages SNS email subscriptions for tag-based notifications.

    Spec section 4.4: users receive notifications for files with specific tags.
    Rubric 2.3.3: must filter by specific watched tags — not all species.

    Subscribe attaches a FilterPolicy matching the MessageAttributes the inference
    Lambda publishes, so users only receive emails for their chosen species.

    Expected request body:
    {
        "operation": "subscribe" | "unsubscribe",
        "email": "user@example.com",
        "species": ["wombat", "magpie"]   <- required for subscribe
    }
    """
    cors_headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'POST,GET,DELETE,OPTIONS'
    }

    try:
        body = json.loads(event.get('body', '{}'))
        operation = body.get('operation')
        email = body.get('email')

        if operation not in ['subscribe', 'unsubscribe']:
            return {'statusCode': 400, 'headers': cors_headers,
                    'body': json.dumps({'error': 'operation must be subscribe or unsubscribe'})}

        if not email:
            return {'statusCode': 400, 'headers': cors_headers,
                    'body': json.dumps({'error': 'email is required'})}

        if operation == 'subscribe':
            species_list = body.get('species', [])
            if not species_list or not isinstance(species_list, list):
                return {'statusCode': 400, 'headers': cors_headers,
                        'body': json.dumps({'error': 'species must be a non-empty list e.g. ["wombat", "magpie"]'})}

            # Normalise to lowercase — must match the tags inference Lambda stores
            species_list = [s.strip().lower() for s in species_list if s.strip()]

            response = sns.subscribe(
                TopicArn=SNS_TOPIC_ARN,
                Protocol='email',
                Endpoint=email,
                ReturnSubscriptionArn=True,
                Attributes={
                    'FilterPolicy': json.dumps({'species': species_list})
                }
            )
            subscription_arn = response.get('SubscriptionArn', '')
            print(f"Subscribed {email} to {species_list}. ARN: {subscription_arn}")

            return {'statusCode': 200, 'headers': cors_headers,
                    'body': json.dumps({
                        'message': (
                            f"Confirmation email sent to {email}. "
                            f"After confirming, you will receive alerts for: {', '.join(species_list)}."
                        ),
                        'subscription_arn': subscription_arn,
                        'species': species_list
                    })}

        # unsubscribe
        paginator = sns.get_paginator('list_subscriptions_by_topic')
        subscription_arn = None
        for page in paginator.paginate(TopicArn=SNS_TOPIC_ARN):
            for sub in page['Subscriptions']:
                if sub['Endpoint'] == email and sub['Protocol'] == 'email':
                    subscription_arn = sub['SubscriptionArn']
                    break
            if subscription_arn:
                break

        if not subscription_arn or subscription_arn == 'PendingConfirmation':
            return {'statusCode': 404, 'headers': cors_headers,
                    'body': json.dumps({'error': f"No confirmed subscription found for {email}"})}

        sns.unsubscribe(SubscriptionArn=subscription_arn)
        print(f"Unsubscribed {email}")

        return {'statusCode': 200, 'headers': cors_headers,
                'body': json.dumps({'message': f"Successfully unsubscribed {email}"})}

    except Exception as e:
        print(f"Error: {str(e)}")
        return {'statusCode': 500, 'headers': cors_headers,
                'body': json.dumps({'error': str(e)})}
