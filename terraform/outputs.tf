output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.proj2_alb.dns_name
}

output "alb_url" {
  description = "Full URL to access the application"
  value       = "http://${aws_lb.proj2_alb.dns_name}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.proj2_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_sg.id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.proj2_tg.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.proj2_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.proj2_service.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for ECS containers"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

# Phase F: Monitoring Outputs
output "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.proj2.dashboard_name}"
}

# Phase G: CI/CD Outputs
output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.proj2_pipeline.name
}

output "codepipeline_url" {
  description = "URL to CodePipeline in AWS Console"
  value       = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.proj2_pipeline.name}/view"
}

output "codestar_connection_arn" {
  description = "CodeStar connection ARN (needs manual approval in console)"
  value       = aws_codestarconnections_connection.github.arn
}

output "codestar_connection_status" {
  description = "CodeStar connection status"
  value       = aws_codestarconnections_connection.github.connection_status
}
