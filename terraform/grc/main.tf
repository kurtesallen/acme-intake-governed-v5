module "cloudtrail" {
  source = "./cloudtrail.tf"
}

module "evidence_vault" {
  source = "./evidence-vault.tf"
}

module "kms" {
  source = "./kms.tf"
}

module "oidc" {
  source = "./oidc-role.tf"
}

module "config_rules" {
  source = "./config-rules.tf"
}
