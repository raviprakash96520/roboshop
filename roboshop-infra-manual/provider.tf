terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket = "roboshop-dev-manual"
    key    = "roboshop-manual"
    region = "us-east-1"
    dynamodb_table = "roboshop-locking-dev-manual"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}