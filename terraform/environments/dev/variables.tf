variable "region" {
  type        = string
  description = "AWS region for this environment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "evidence_bucket_name" {
  type        = string
  description = "Evidence vault bucket name"
}
