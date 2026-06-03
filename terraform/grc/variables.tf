variable "region" {
  type        = string
  description = "AWS region for GRC infrastructure"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, prod, etc.)"
}

variable "evidence_bucket_name" {
  type        = string
  description = "Name of the evidence vault bucket"
}
