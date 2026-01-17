# Security Group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "proj2-alb-sg"
  description = "Security group for ALB - allows HTTP from internet"
  vpc_id      = aws_vpc.proj2_vpc.id

  # Inbound: Allow HTTP from anywhere
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow all traffic (ALB needs to reach ECS tasks)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "proj2-alb-sg"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name        = "proj2-ecs-sg"
  description = "Security group for ECS tasks - allows traffic from ALB only"
  vpc_id      = aws_vpc.proj2_vpc.id

  # Inbound: Allow container port from ALB only
  ingress {
    description     = "Container port from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Outbound: Allow HTTPS for ECR image pull and CloudWatch logs
  egress {
    description = "HTTPS for ECR and CloudWatch"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow HTTP for health checks and general connectivity
  egress {
    description = "HTTP for general connectivity"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "proj2-ecs-sg"
  }
}
