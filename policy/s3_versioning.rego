package hipaa.s3_versioning

default allow = false

allow {
  input.resource_type == "aws_s3_bucket"
  input.data.versioning_enabled == true
}
