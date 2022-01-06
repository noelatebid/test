
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.46.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.3.2"
    }
    local = {
      source = "hashicorp/local"
      version = "1.4.0"
    }
  }
}

//provider "local" {
//  version = "~> 1.2"
//}

//provider "null" {
//  version = "~> 2.1"
//}

//provider "template" {
//  version = "~> 2.1"
//}
