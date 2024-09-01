terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #access_key = "ASIATTOTKGPM2TIORGX6"
  #secret_key = "mjOdKpj4kvyusTY/W02+AsqqnQnCUHLXWelFLYKg"
  assume_role {
    role_arn = "arn:aws:iam::247940658137:role/terraform"
  }
}