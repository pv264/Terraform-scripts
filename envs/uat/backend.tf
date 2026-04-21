terraform {
  backend "s3" {
    bucket         = "venkat-terraform-state-bucket456"
    key            = "uat/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}