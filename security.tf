# ------------------------------
# 1. ALB Security Group (Public Facing)
# ------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "phase2-infra-alb-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "Controls traffic to the Application Load Balancer"

  # Allow public HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow public HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 2. Haystack Security Group
# ------------------------------
resource "aws_security_group" "haystack_sg" {
  name        = "phase2-infra-haystack-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "For the Haystack application instances"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from ANYWHERE on the application port
  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # MODIFIED: Was restricted to the ALB
  }

  # Exporter/Monitoring ports
  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "cAdvisor"
    from_port   = 9400
    to_port     = 9400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Generic Monitoring"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 3. vLLM Security Group
# ------------------------------
resource "aws_security_group" "vllm_sg" {
  name        = "phase2-infra-vllm-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "For the vLLM instance"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from ANYWHERE on the application port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # MODIFIED: Was restricted to Haystack
  }

  # Exporter/Monitoring ports
  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "cAdvisor"
    from_port   = 9400
    to_port     = 9400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Generic Monitoring"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 4. Embedding Security Group
# ------------------------------
resource "aws_security_group" "embed_sg" {
  name        = "phase2-infra-embed-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "For the Embedding instance"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from ANYWHERE on the application port
  ingress {
    from_port   = 9020
    to_port     = 9020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # MODIFIED: Was restricted to Haystack
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 5. Milvus DB Security Group
# ------------------------------
resource "aws_security_group" "db" {
  name        = "phase2-infra-milvus-db-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "For the Milvus DB instance"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from ANYWHERE on the database port
  ingress {
    from_port   = 19530
    to_port     = 19530
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # MODIFIED: Was restricted to Haystack
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 6. Redis Security Group
# ------------------------------
resource "aws_security_group" "redis_sg" {
  name        = "phase2-infra-redis-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "For the Redis instance"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from ANYWHERE on the Redis port
  ingress {
    from_port   = 6380
    to_port     = 6380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # MODIFIED: Was restricted to Haystack
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------
# 7. Monitoring Security Group
# ------------------------------
resource "aws_security_group" "monitoring_sg" {
  name        = "phase2-infra-monitoring-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "For the Monitoring instance"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow public access to view dashboards
  ingress {
    description = "Langfuse UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Grafana UI"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Prometheus UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Added monitoring ports
  ingress {
    description = "Loki"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jaeger UI"
    from_port   = 16686
    to_port     = 16686
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jaeger Collector"
    from_port   = 4317
    to_port     = 4317
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow other instances to send monitoring data from ANYWHERE
  ingress {
    description = "Allow metrics/logs from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # MODIFIED: Was restricted to other SGs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

