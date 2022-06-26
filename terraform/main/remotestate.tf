# S3 bucket to store the remote state file
terraform {
  backend "s3" {
    bucket  = "terraform-thanosgkara-iam-test"
    key     = "eu-central-1/iam/terraform.tfstate"
    region  = "eu-central-1"
    profile = "thanos-master"
  }
}