
# ==================================================
# VPC Configuration
# ==================================================

environment = "dev"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# ==================================================
# EC2 Configuration
# ==================================================

instance_type = "t3.micro"

root_volume_size = 30

enable_termination_protection = true

