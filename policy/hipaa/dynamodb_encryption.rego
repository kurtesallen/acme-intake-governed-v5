package compliance.hipaa.dynamodb_encryption

# METADATA
# title: HIPAA — DynamoDB tables must use SSE-KMS
# custom:
#   framework: hipaa
#   controls:
#     - "164.312(a)(2)(iv)"
#   severity: high

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "aws_dynamodb_table"

  rc.change.after.server_side_encryption.kms_key_arn == null

  msg := sprintf("DynamoDB table %v must use SSE-KMS encryption", [rc.address])
}
