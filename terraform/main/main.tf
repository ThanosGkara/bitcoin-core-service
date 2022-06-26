terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
  }

  required_version = ">= 1.2.3"
}

provider "aws" {
  profile = "thanos-master"
  region  = "eu-central-1"
}


# Run ../modules/iam
module "iam" {
  source = "../modules/iam"

  env   = var.env
  owner = var.owner
  stack = var.stack

}