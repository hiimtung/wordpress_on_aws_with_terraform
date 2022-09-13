provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  backend "s3" {
    bucket         = "tfstate-236143222623"
    key            = "s3://tfstate-236143222623/aws-wordpress/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "lockstate"
  }
}