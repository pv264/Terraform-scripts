
# ==================================================
# Environment
# ==================================================

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

# ==================================================
# Networking
# ==================================================

variable "vpc_id" {
  description = "VPC ID where EC2 will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID for EC2"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

# ==================================================
# EC2 Configuration
# ==================================================

variable "ami_id" {
  description = "Approved Amazon Machine Image ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "Root volume size must be at least 8 GB."
  }
}

# ==================================================
# Security Configuration
# ==================================================

variable "enable_termination_protection" {
  description = "Enable EC2 termination protection"
  type        = bool
  default     = true
}

