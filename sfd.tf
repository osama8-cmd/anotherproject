provider "aws" {
  region = "us-east-1"
}

# Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "simple-alb-sg"
  description = "Allow HTTP"
  vpc_id      = "vpc-xxxxxxx" # <-- replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
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

# Application Load Balancer
resource "aws_lb" "simple_alb" {
  name               = "simple-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-xxxxxxx", "subnet-yyyyyyy"] # <-- replace with your subnet IDs

  tags = {
    Name = "simple-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "simple-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-xxxxxxx" # <-- same VPC as above
}

# Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.simple_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello from ALB!"
      status_code  = "200"
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.simple_alb.dns_name
}
