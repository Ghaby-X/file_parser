
import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)


def lambda_handler(event, context):
    print("lambda function has been invoked")

    for record in event['Records']:
        s3_info = record['s3']
        key = s3_info['object']['key']
        size = s3_info['object'].get('size', 0)

        upload_time = record['eventTime']

        metadata = {
            'file_name': key,
            'size': size,
            'upload_time': upload_time,
        }

        print(f"metadata has been successfully parsed")
        print(f"metadata: {metadata}")

        # saving to dynamodb
        try:
            table.put_item(Item=metadata)
            print(f"Metadata saved for {key}")
        except Exception as e:
            print(f"Error saving metadata: {e}")

    return {
        'statusCode': 200,
        'message': 'Metadata successfully saved!'
    }
