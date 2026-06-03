resource "aws_kms_key" "phi_cmk" {
  description             = "HIPAA PHI CMK for DynamoDB, S3, and evidence signing"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Purpose = "phi-encryption"
    ManagedBy = "terraform"
  }
}

resource "aws_kms_alias" "phi_cmk_alias" {
  name          = "alias/phi-cmk"
  target_key_id = aws_kms_key.phi_cmk.key_id
}
