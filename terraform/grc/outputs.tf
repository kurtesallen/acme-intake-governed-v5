output "phi_kms_key_arn" {
  value = aws_kms_key.phi_cmk.arn
}

output "evidence_vault_bucket" {
  value = data.aws_s3_bucket.evidence_vault.id
}

output "github_grc_role_arn" {
  value = aws_iam_role.github_grc_role.arn
}
