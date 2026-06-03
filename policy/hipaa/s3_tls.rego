package compliance.hipaa.s3_tls

# METADATA
# title: HIPAA — S3 buckets must enforce TLS
# custom:
#   framework: hipaa
#   controls:
#     - "164.312(e)(1)"
#   severity: high

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "aws_s3_bucket_policy"

  # Bind the index instead of using `_`
  some i
  stmt := rc.change.after.Statement[i]

  not stmt.Condition.Bool["aws:SecureTransport"] == "true"

  msg := sprintf("S3 bucket policy %v must enforce TLS (aws:SecureTransport)", [rc.address])
}
