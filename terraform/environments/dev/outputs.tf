output "evidence_bucket" {
  value = module.grc.evidence_bucket
}

output "kms_key_arn" {
  value = module.grc.kms_key_arn
}

output "config_rule_ids" {
  value = module.grc.config_rule_ids
}
