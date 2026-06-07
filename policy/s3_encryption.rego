package hipaa.s3_encryption

default allow = false

allow {
  input.resource_type == "aws_s3_bucket"
  input.data.server_side_encryption == true
}
