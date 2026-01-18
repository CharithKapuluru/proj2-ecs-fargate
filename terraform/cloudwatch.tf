# CloudWatch Log Group for ECS Container Logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/proj2-app"
  retention_in_days = 7

  tags = {
    Name = "proj2-ecs-logs"
  }
}
