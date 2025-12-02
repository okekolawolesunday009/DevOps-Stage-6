terraform {
  backend "s3" {
    bucket         = "devops-stage-6-terraform-state"
    key            = "devops-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}