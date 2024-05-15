import boto3
import json
import os

s3_client = boto3.client('s3')
ec2_client = boto3.client('ec2')
ses_client = boto3.client('ses')

def get_compliant_ami():
    ami_bucket = os.environ['S3_BUCKET']
    ami_key = os.environ['S3_KEY']
    
    getBucketObject = s3_client.get_object(Bucket=ami_bucket, Key=ami_key)
    # getBucketObject['Body'].read() -> byte string json -> convert that into dict json.load()
    data = json.loads(getBucketObject['Body'].read())
    #print(getBucketObject['Body'].read())
    # return as tuple
    return data['ami_id'], data['compliance_report_email']

def find_non_compliant_instances(compliant_ami_id):
    # gives reservations
    # getting reservation object each reservation can include multiple EC2s
    # inside reservation object there's a 'Instances' key -> list of instances
    instances = ec2_client.describe_instances(
        Filters=[
            {   
                'Name': 'image-id', 
                'Values': [compliant_ami_id]
            }
        ]
    )['Reservations']
    
    non_compliant_instances = []
    for reservation in instances:
        for instance in reservation['Instances']:
            if instance['ImageId'] != compliant_ami_id:
                bad_instance = instance['InstanceId']
                non_compliant_instances.append(bad_instance)
    
    return non_compliant_instances

def send_report(non_compliant_instances, email):

    subject = "Non-compliant EC2 Found"
    body = "instances that are non compliant {}".format(non_compliant_instances)
    
    ses_client.send_email(
        Source=email,
        Destination={'ToAddresses': [email]},
        Message={
            'Subject': {'Data': subject},
            'Body': {'Text': {'Data': body}}
        }
    )

def lambda_call(event, context):
    compliant_ami_id, email = get_compliant_ami()
    non_compliant_instances = find_non_compliant_instances(compliant_ami_id)
    #if not empty array
    if non_compliant_instances:
        send_report(non_compliant_instances, email)
        ec2_client.terminate_instances(InstanceIds=non_compliant_instances)

    return {
        'statusCode': 200,
        'body': json.dumps('Compliance check complete.')
    }
