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
