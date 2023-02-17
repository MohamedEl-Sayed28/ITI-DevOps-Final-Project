terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46"
    }
  }
}

provider "aws" {
  region = var.region

  shared_config_files      = ["/home/mohamed/.aws/config"]
  shared_credentials_files = ["/home/mohamed/.aws/credentials"]
  profile                  = ""

  # other options for authentication
}
