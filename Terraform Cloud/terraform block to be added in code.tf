terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # The source of the AWS provider plugin
      version = "~> 4.0"        # Specifies a compatible version of the AWS provider
    }
  }
}

variable "accesskey" {}
variable "secretkey" {}

provider "aws" {
  region     = "ap-south-1"    # The AWS region where resources will be created
  access_key = var.accesskey    # Access key (provided via a variable)
  secret_key = var.secretkey    # Secret key (provided via a variable)
}
