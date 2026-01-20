# ECS Cluster
resource "aws_ecs_cluster" "proj2_cluster" {
  name = "proj2-cluster"

  tags = {
    Name = "proj2-cluster"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "proj2_task" {
  family                   = "proj2-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "proj2-app"
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = [
        {
          name  = "ENVIRONMENT"
          value = "production"
        }
      ]
    }
  ])

  tags = {
    Name = "proj2-task"
  }
}

# ECS Service
resource "aws_ecs_service" "proj2_service" {
  name            = "proj2-service"
  cluster         = aws_ecs_cluster.proj2_cluster.id
  task_definition = aws_ecs_task_definition.proj2_task.arn
  desired_count   = var.task_count

  # Use capacity provider strategy instead of launch_type for Fargate Spot
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4
    base              = 0
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1  # At least 1 task on regular Fargate for reliability
  }

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.proj2_tg.arn
    container_name   = "proj2-app"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 60

  # Ignore desired_count changes from auto-scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "proj2-service"
  }
}
