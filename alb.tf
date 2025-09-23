# ------------------------------
# Application Load Balancer (ALB)
# ------------------------------

# 1. Create the ALB itself
resource "aws_lb" "haystack_alb" {
  name               = "phase2-infra-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids # <-- UPDATED from .default to .public

  enable_deletion_protection = false

  tags = {
    Name = "phase2-infra-alb"
  }
}

# 2. Create the Target Group for the Haystack instances
resource "aws_lb_target_group" "haystack" {
  name        = "phase2-infra-haystack-tg"
  port        = 8888
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "phase2-infra-haystack-tg"
  }
}

# 3. Create the Listener for port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.haystack_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.haystack.arn
  }
}

# 4. Create the new Listener for port 8888
resource "aws_lb_listener" "http_8888" {
  load_balancer_arn = aws_lb.haystack_alb.arn
  port              = "8888"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.haystack.arn
  }
}

# 5. Attach the Haystack instances to the target group (as requested)
resource "aws_lb_target_group_attachment" "haystack_attachment" {
  count = 2 # Attach two instances

  target_group_arn = aws_lb_target_group.haystack.arn
  target_id        = aws_instance.haystack[count.index].id # This resource will be defined in your ec2.tf file
  port             = 8888
}
