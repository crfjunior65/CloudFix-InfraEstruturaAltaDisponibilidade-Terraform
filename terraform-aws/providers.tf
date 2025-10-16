terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" #  5.94.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket  = "dolfy-shield-tfstate"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    #dynamodb_table = "terraform-locks"
  }

}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
