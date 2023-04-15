terraform {
  backend "s3" {
    bucket = "arstk8-tf-state"
    region = "us-east-1"
    key    = "eks-demo/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}