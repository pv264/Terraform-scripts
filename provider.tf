terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }

  backend "s3" {
    bucket         = "testpavan"
    key            = "phase-2- test"
    region         = "us-east-1"
    # For better safety, you can create a DynamoDB table and uncomment the line below
    # dynamodb_table = "terraform-state-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}
