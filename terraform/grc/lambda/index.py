import boto3
import json
import os

sns = boto3.client("sns")
s3 = boto3.client("s3")

TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

def lambda_handler(event, context):
    bucket = event["detail"]["requestParameters"]["bucketName"]

    findings = []

    enc = s3.get_bucket_encryption(Bucket=bucket)
    rules = enc.get("ServerSideEncryptionConfiguration", {}).get("Rules", [])
    if not rules or rules[0]["ApplyServerSideEncryptionByDefault"]["SSEAlgorithm"] != "aws:kms":
        findings.append("Bucket missing SSE-KMS encryption")

    ver = s3.get_bucket_versioning(Bucket=bucket)
    if ver.get("Status") != "Enabled":
        findings.append("Bucket versioning not enabled")

    if findings:
        message = f"HIPAA violation detected for bucket {bucket}: " + ", ".join(findings)
        sns.publish(TopicArn=TOPIC_ARN, Message=message)

    return {"status": "ok"}
