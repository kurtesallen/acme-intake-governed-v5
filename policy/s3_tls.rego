package hipaa.s3_tls

default allow = false

allow {
  input.resource_type == "aws_s3_bucket"
  input.data.encryption_in_transit == true
}
