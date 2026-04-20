provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  az                  = var.az
}

module "ec2" {
  source = "../../modules/ec2"

  ami           = var.ami
  instance_type = var.instance_type

  subnet_id = module.vpc.public_subnet_id
  sg_id     = module.sg.sg_id
}

module "sg" {
  source = "../../modules/security_groups"

  vpc_id = module.vpc.vpc_id
}