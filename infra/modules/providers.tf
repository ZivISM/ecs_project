###############################################################################
# AWS Provider
###############################################################################
provider "aws" {
  region = var.region
}

###############################################################################
# Terraform Providers
###############################################################################
terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  required_version = "~> 1.0"
}






