# Application Load Balancer
resource "aws_lb" "proj2_alb" {
  name               = "proj2-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
  enable_http2              = true

  tags = {
    Name = "proj2-alb"
  }
}

# Target Group for ECS Tasks
resource "aws_lb_target_group" "proj2_tg" {
  name        = "proj2-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.proj2_vpc.id
  target_type = "ip" # Required for Fargate

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name = "proj2-tg"
  }
}

# ALB Listener (HTTP:80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.proj2_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proj2_tg.arn
  }

  tags = {
    Name = "proj2-alb-listener"
  }
}
