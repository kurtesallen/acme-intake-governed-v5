############################################
# Evidence Vault Bucket (SAFE, IMMUTABLE)
############################################

# IMPORTANT:
# This bucket ALREADY EXISTS and contains v4 evidence.
# Terraform must NOT create or destroy it.
# We declare it as a data source instead of a resource.

data "aws_s3_bucket" "evidence_vault" {
  bucket = "acme-evidence-vault-c1aa6b62"
}

# Versioning, SSE, Object Lock, and Public Access Block
# are ALREADY configured on the bucket.
# Terraform must NOT manage them anymore.

# These are intentionally removed to prevent deletion:
# - aws_s3_bucket.evidence_vault
# - aws_s3_bucket_versioning.evidence_vault_versioning
# - aws_s3_bucket_server_side_encryption_configuration.evidence_vault_sse
# - aws_s3_bucket_object_lock_configuration.evidence_vault_lock
# - aws_s3_bucket_public_access_block.evidence_vault_block

# Terraform will ONLY manage the bucket policy in cloudtrail-bucket-policy.tf
