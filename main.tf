terraform {
  backend "remote" {
    organization = "ourtilt"

    workspaces {
      prefix = "tilt-"
    }
  }
}

provider "aws" {
//  version = ">= 2.28.1"
  region  = "us-west-2"
}

locals {
  prefix = "tilt-${var.environment}"

  default_tags = {
    Environment = var.environment
    ManagedBy = "Terraform"
  }

  s3_bucket_name = "tilt-app-${var.environment}"
}


variable "environment" {
  description = "Env"
}

variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}

variable "pgsql_password" {
  description = "Database password"
}