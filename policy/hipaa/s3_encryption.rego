package compliance.hipaa.s3_encryption

# METADATA
# title: HIPAA — S3 buckets must use SSE-KMS
# custom:
#   framework: hipaa
#   controls:
#     - "164.312(a)(2)(iv)"
#   severity: high

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "aws_s3_bucket_server_side_encryption_configuration"

  algo := rc.change.after.rule[0].apply_server_side_encryption_by_default.sse_algorithm
  algo != "aws:kms"

  msg := sprintf("S3 bucket %v must use SSE-KMS encryption", [rc.address])
}
