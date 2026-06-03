resource "aws_s3_bucket" "evidence_vault" {
  bucket = "acme-evidence-vault-${random_id.suffix.hex}"

  object_lock_enabled = true

  tags = {
    Purpose = "audit-evidence"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "evidence_vault_versioning" {
  bucket = aws_s3_bucket.evidence_vault.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "evidence_vault_lock" {
  bucket = aws_s3_bucket.evidence_vault.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 365
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "evidence_vault_sse" {
  bucket = aws_s3_bucket.evidence_vault.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.phi_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
