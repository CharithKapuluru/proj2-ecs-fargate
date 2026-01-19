variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID for ECR repository"
  type        = string
  default     = "501894534533"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  description = "Port exposed by the Docker container"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "Fargate CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate memory in MB"
  type        = number
  default     = 512
}

variable "task_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "proj2-app"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "v1"
}

# Phase F: Monitoring Variables
variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = "kapulurucharith@gmail.com"
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
}

# Phase G: CI/CD Variables
variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "CharithKapuluru/proj2-ecs-fargate"
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}
