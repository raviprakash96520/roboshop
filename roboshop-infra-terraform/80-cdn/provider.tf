terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.0"
    }
  }

  backend "s3" {
    bucket = "roboshop-infra-state-dev"
    key    = "roboshop-cdn"
    region = "us-east-1"
    dynamodb_table = "roboshop-locking-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}