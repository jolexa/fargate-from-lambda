#!/usr/bin/env python

import os
import logging

import boto3

logging.getLogger('boto3').setLevel(logging.CRITICAL)
logging.getLogger('botocore').setLevel(logging.CRITICAL)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def handler(event, context):
    logger.debug(event)
    client = boto3.client('ecs')

    response = client.run_task(
        cluster=os.environ['ECSCluster'],
        taskDefinition=os.environ['ECSTaskArn'],
        count=1,
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [
                    os.environ['ECSSubnet'],
                ],
                'securityGroups': [
                    os.environ['ECSSecGroup'],
                ],
                'assignPublicIp': 'ENABLED'
            }
        }
    )
    logger.debug(response)

if __name__== "__main__":
    event = {}
    context = {}
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    handler(event, context)
