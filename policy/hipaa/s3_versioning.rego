package compliance.hipaa.s3_versioning

# METADATA
# title: HIPAA — S3 buckets must have versioning enabled
# custom:
#   framework: hipaa
#   controls:
#     - "164.308(a)(7)"
#   severity: medium

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "aws_s3_bucket_versioning"

  rc.change.after.versioning_configuration.status != "Enabled"

  msg := sprintf("S3 bucket %v must have versioning enabled", [rc.address])
}
