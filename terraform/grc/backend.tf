terraform {
  backend "s3" {
    bucket         = "acme-terraform-state-846470648858"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-terraform-locks"
    encrypt        = true
  }
}
