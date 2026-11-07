
# ==================================================
# VPC MODULE
# ==================================================

module "vpc" {
  source = "../../modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ==================================================
# EC2 MODULE
# ==================================================

module "ec2" {
  source = "../../modules/ec2"

  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.private_subnet_ids[0]
  private_subnet_ids = module.vpc.private_subnet_ids

  ami_id         = var.ami_id
  instance_type  = var.instance_type
  root_volume_size = var.root_volume_size

  enable_termination_protection = var.enable_termination_protection
}

