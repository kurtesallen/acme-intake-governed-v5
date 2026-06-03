module "grc" {
  source = "../../grc"

  region               = var.region
  environment          = var.environment
  evidence_bucket_name = var.evidence_bucket_name
}
