terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-shashi2026"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}