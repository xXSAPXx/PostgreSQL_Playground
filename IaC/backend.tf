
# Configure Terraform Remote Backend: 
terraform {
  backend "s3" {
    bucket       = "terraform-postgresql-playground-tfstate"
    key          = "terraform-postgresql.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

