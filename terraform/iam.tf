# IAM Role for ECS Task Execution
# This role allows ECS to pull images from ECR and write logs to CloudWatch

# Trust policy: Allow ECS tasks to assume this role
data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create the IAM role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "proj2-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json

  tags = {
    Name = "proj2-ecs-task-execution-role"
  }
}

# Attach AWS managed policy for ECS task execution
# This policy includes permissions for ECR and CloudWatch Logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
