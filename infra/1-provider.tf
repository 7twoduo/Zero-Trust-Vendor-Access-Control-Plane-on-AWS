terraform {
  required_version = ">= 1.14.8"

  backend "s3" {
    bucket  = "deathless-godx"
    key     = "fedramp-zero-trust-mvp/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    #  use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
# This is the region where the provider will create resources. It can be overridden by setting the AWS_REGION environment variable or by specifying it in the provider block.
provider "aws" {
  region = var.aws_region
}