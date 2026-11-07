
# ==================================================
# VPC Configuration
# ==================================================

environment = "prod"

vpc_cidr = "10.2.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.2.1.0/24",
  "10.2.2.0/24"
]

private_subnet_cidrs = [
  "10.2.11.0/24",
  "10.2.12.0/24"
]

# ==================================================
# EC2 Configuration
# ==================================================

instance_type = "t3.medium"

root_volume_size = 50

enable_termination_protection = true

