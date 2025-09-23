# ------------------------------
# DB EC2 Instance (Milvus)
# ------------------------------
resource "aws_instance" "db" {
  depends_on = [aws_instance.embed]

  ami                         = data.aws_ami.rhel9.id
  instance_type               = var.db_instance_type
  key_name                    = "haystack-db-dev-tf"
  vpc_security_group_ids      = [aws_security_group.db.id]
  iam_instance_profile        = "ansible-tf-vllm"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.public.ids[2] # Assigning a public subnet

  root_block_device {
    volume_size = var.db_ebs_volume
    volume_type = "gp3"
  }

  tags = {
    Name = "genai-milvus-db-staging"
  }
}

resource "null_resource" "db_setup" {
  depends_on = [aws_instance.db]
  connection {
    type        = "ssh"
    host        = aws_instance.db.public_ip
    user        = "ec2-user"
    private_key = file(var.db_private_key_path)
  }
  provisioner "file" {
    source      = "db-setup.sh"
    destination = "/tmp/db-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/db-setup.sh",
      "/tmp/db-setup.sh"
    ]
  }
}

# ------------------------------
# Embedding EC2 Instance (Single)
# ------------------------------
resource "aws_instance" "embed" {
  depends_on = [aws_instance.vllm]

  ami                         = data.aws_ami.rhel9.id
  instance_type               = var.embed_instance_type
  key_name                    = "haystack-vllm-dev-tf"
  vpc_security_group_ids      = [aws_security_group.embed_sg.id]
  iam_instance_profile        = "ansible-tf-vllm"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.g6e_subnets.ids[0] # Assigning a public subnet

  root_block_device {
    volume_size = var.embed_ebs_volume
    volume_type = "gp3"
  }

  tags = {
    Name = "genai-embed-staging"
  }
}

resource "null_resource" "remote_exec_packages" {
  depends_on = [aws_instance.embed]
  triggers = {
    script_checksum = filesha256("embed-packages-setup.sh")
  }

  connection {
    type        = "ssh"
    host        = aws_instance.embed.public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "embed-packages-setup.sh"
    destination = "/tmp/embed-packages-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/embed-packages-setup.sh",
      "sh -x /tmp/embed-packages-setup.sh"
    ]
  }
}

resource "time_sleep" "wait_for_embed_instance" {
  depends_on      = [null_resource.remote_exec_packages]
  create_duration = "90s"
}

resource "null_resource" "embed_setup" {
  depends_on = [time_sleep.wait_for_embed_instance]

  connection {
    type        = "ssh"
    host        = aws_instance.embed.public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "embed-app-setup.sh"
    destination = "/tmp/embed-app-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/embed-app-setup.sh",
      "/tmp/embed-app-setup.sh"
    ]
  }
}

# ------------------------------
# vLLM EC2 Instances
# ------------------------------
resource "aws_instance" "vllm" {
  count                       = 1
  ami                         = data.aws_ami.rhel9.id
  instance_type               = var.vllm_instance_type
  key_name                    = "haystack-vllm-dev-tf"
  vpc_security_group_ids      = [aws_security_group.vllm_sg.id]
  iam_instance_profile        = "ansible-tf-vllm"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.g6e_subnets.ids[0] # Assigning a public subnet

  root_block_device {
    volume_size = var.vllm_ebs_volume
    volume_type = "gp3"
    iops        = var.vllm_ebs_iops
  }

  tags = {
    Name = "genai-vllm-${count.index + 1}"
  }
}

resource "null_resource" "vllm_setup" {
  count      = 1
  depends_on = [aws_instance.vllm]
  connection {
    type        = "ssh"
    host        = aws_instance.vllm[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }
  provisioner "file" {
    source      = "vllm-packages-setup.sh"
    destination = "/tmp/vllm-packages-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vllm-packages-setup.sh",
      "/tmp/vllm-packages-setup.sh"
    ]
  }
}

resource "time_sleep" "wait_for_vllm_instance" {
  count           = 1
  depends_on      = [null_resource.vllm_setup]
  create_duration = "90s"
}

resource "null_resource" "vllm_app" {
  count      = 1
  depends_on = [time_sleep.wait_for_vllm_instance]

  connection {
    type        = "ssh"
    host        = aws_instance.vllm[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "vllm-app-setup.sh"
    destination = "/tmp/vllm-app-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vllm-app-setup.sh",
      "/tmp/vllm-app-setup.sh"
    ]
  }
}

# ------------------------------

# ------------------------------
# Haystack EC2 Instances (2)
# ------------------------------
resource "aws_instance" "haystack" {
  depends_on = [aws_instance.redis]

  count                       = 2
  ami                         = data.aws_ami.rhel9.id
  instance_type               = "c7i.4xlarge"
  key_name                    = "haystack-vllm-dev-tf"
  vpc_security_group_ids      = [aws_security_group.haystack_sg.id]
  iam_instance_profile        = "ansible-tf-vllm"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.c7i_subnets.ids[count.index % length(data.aws_subnets.c7i_subnets.ids)]

  root_block_device {
    volume_size = 200
    volume_type = "gp3"
  }

  tags = {
    Name = "genai-haystack-${count.index + 1}"
  }
}

resource "null_resource" "haystack_packages_setup" {
  count      = 2
  depends_on = [aws_instance.haystack]

  connection {
    type        = "ssh"
    host        = aws_instance.haystack[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "haystack-packages-setup.sh"
    destination = "/tmp/haystack-packages-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/haystack-packages-setup.sh",
      "/tmp/haystack-packages-setup.sh"
    ]
  }
}

# NEW: This resource will pause to allow for a reboot
resource "time_sleep" "wait_for_haystack_reboot" {
  count           = 2
  depends_on      = [null_resource.haystack_packages_setup]
  create_duration = "90s"
}

resource "null_resource" "haystack_app_setup" {
  count      = 2
  # UPDATED: This now depends on the sleep timer
  depends_on = [time_sleep.wait_for_haystack_reboot]

  connection {
    type        = "ssh"
    host        = aws_instance.haystack[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "haystack-setup.sh"
    destination = "/tmp/haystack-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/haystack-setup.sh",
      "/tmp/haystack-setup.sh"
    ]
  }
}

# ------------------------------
# Redis EC2 Instance
# ------------------------------
resource "aws_instance" "redis" {
  depends_on = [aws_instance.db]

  ami                         = data.aws_ami.rhel9.id
  instance_type               = "r7i.2xlarge"
  key_name                    = "haystack-vllm-dev-tf"
  vpc_security_group_ids      = [aws_security_group.redis_sg.id]
  iam_instance_profile        = "ansible-tf-vllm"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.r7i_subnets.ids[0] # Assigning a public subnet

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "genai-redis"
  }
}

resource "null_resource" "redis_setup" {
  depends_on = [aws_instance.redis]

  connection {
    type        = "ssh"
    host        = aws_instance.redis.public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "redis-setup.sh"
    destination = "/tmp/redis-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/redis-setup.sh",
      "/tmp/redis-setup.sh"
    ]
  }
}

# ------------------------------
# Monitoring EC2 Instance
# ------------------------------
resource "aws_instance" "monitoring" {
  depends_on = [aws_instance.haystack]

  ami                         = data.aws_ami.rhel9.id
  instance_type               = "m5.large" # Changed from t3.large
  key_name                    = "haystack-vllm-dev-tf"
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]
  iam_instance_profile        = "ansible-tf-vllm"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.r7i_subnets.ids[0] # Assigning a public subnet

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "genai-monitoring"
  }
}

resource "null_resource" "monitoring_setup" {
  depends_on = [aws_instance.monitoring]

  connection {
    type        = "ssh"
    host        = aws_instance.monitoring.public_ip
    user        = "ec2-user"
    private_key = file(var.vllm_private_key_path)
  }

  provisioner "file" {
    source      = "monitoring-setup.sh"
    destination = "/tmp/monitoring-setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/monitoring-setup.sh",
      "/tmp/monitoring-setup.sh"
    ]
  }
}

