resource "aws_cloudtrail" "main" {
  name                          = "acme-cloudtrail"
  s3_bucket_name                = data.aws_s3_bucket.evidence_vault.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
