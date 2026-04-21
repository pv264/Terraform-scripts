output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "security_group_id" {
  value = module.sg.sg_id
}

output "instance_id" {
  value = module.ec2.instance_id
}