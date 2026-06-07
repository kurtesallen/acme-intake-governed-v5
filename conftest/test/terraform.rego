package terraform.s3

# Deny if S3 bucket does not have SSE enabled
deny[msg] {
  some i
  rc := input.resource_changes[i]
  rc.type == "aws_s3_bucket"

  not rc.change.after.server_side_encryption_configuration
  msg := sprintf("S3 bucket %s must have server-side encryption enabled", [rc.name])
}

# Deny if S3 bucket does not have versioning enabled
deny[msg] {
  some i
  rc := input.resource_changes[i]
  rc.type == "aws_s3_bucket"

  not rc.change.after.versioning.enabled
  msg := sprintf("S3 bucket %s must have versioning enabled", [rc.name])
}
