data "aws_vpc" "default" {
  default = true
}

# Data source for general instances (like Monitoring)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Data source for g6e instances (vLLM, Embed)
data "aws_subnets" "g6e_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  }
}

# Data source for c7i instances (Haystack, Redis)
data "aws_subnets" "c7i_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# Data source for r7i instances (DB)
data "aws_subnets" "r7i_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
  # Assuming similar availability constraints to be safe
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}


#get AMI details
data "aws_ami" "rhel9" { # <-- NAME CORRECTED from "r7i" to "rhel9"
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9.5.0_HVM-*-x86_64-0-Hourly2-GP3"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # Official AWS AMIs
}

