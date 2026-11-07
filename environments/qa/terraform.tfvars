
# ==================================================
# VPC Configuration
# ==================================================

environment = "qa"

vpc_cidr = "10.1.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.1.1.0/24",
  "10.1.2.0/24"
]

private_subnet_cidrs = [
  "10.1.11.0/24",
  "10.1.12.0/24"
]

# ==================================================
# EC2 Configuration
# ==================================================

instance_type = "t3.small"

root_volume_size = 30

enable_termination_protection = false

