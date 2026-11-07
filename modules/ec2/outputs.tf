
# EC2 Instance ID

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

# EC2 Private IP

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

# EC2 Availability Zone

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.main.availability_zone
}

# EC2 Security Group ID

output "security_group_id" {
  description = "Security group ID attached to EC2"
  value       = aws_security_group.ec2.id
}

# IAM Role Name

output "iam_role_name" {
  description = "IAM role attached to EC2"
  value       = aws_iam_role.ec2.name
}

