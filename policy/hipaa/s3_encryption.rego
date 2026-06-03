package hipaa.s3_encryption

deny[msg] {
  some i
  rc := input.resource_changes[i]
  rc.type == "aws_s3_bucket_server_side_encryption_configuration"

  algo := rc.change.after.rule[0].apply_server_side_encryption_by_default.sse_algorithm
  algo != "aws:kms"

  msg := sprintf("S3 bucket %v must use SSE-KMS encryption", [rc.address])
}
