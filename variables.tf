variable "vllm_instance_type" {
  default = "g6e.12xlarge"
}

variable "db_instance_type" {
  default = "r7i.2xlarge"
}

variable "embed_instance_type" {
  default = "g6e.xlarge"
}

variable "vllm_ebs_volume" {
  default = 150
}
variable "vllm_ebs_iops" {
  description = "The number of IOPS for the gp3 root volume."
  type        = number
  default     = 6000 # Default for gp3 is 3000,  increased to 6000
}

variable "embed_ebs_volume" {
  default = 150
}

variable "db_ebs_volume" {
  default = 150
}

variable "db_private_key_path" {
  description = "Path to the private key for the DB instance"
  type        = string
}

variable "vllm_private_key_path" {
  description = "Path to the private key for the VLLM instance"
  type        = string
}
