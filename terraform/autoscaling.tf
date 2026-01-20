# =============================================================================
# PHASE H: AUTO-SCALING WITH FARGATE SPOT + SCHEDULED SCALING
# =============================================================================

# -----------------------------------------------------------------------------
# ECS Cluster Capacity Providers (Fargate Spot)
# -----------------------------------------------------------------------------
resource "aws_ecs_cluster_capacity_providers" "proj2" {
  cluster_name = aws_ecs_cluster.proj2_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}

# -----------------------------------------------------------------------------
# Application Auto Scaling Target
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${aws_ecs_cluster.proj2_cluster.name}/${aws_ecs_service.proj2_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# -----------------------------------------------------------------------------
# CPU-Based Target Tracking Scaling Policy
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "proj2-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# -----------------------------------------------------------------------------
# Request Count Based Scaling Policy (ALB requests per target)
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "ecs_request_policy" {
  name               = "proj2-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.proj2_alb.arn_suffix}/${aws_lb_target_group.proj2_tg.arn_suffix}"
    }
    target_value       = 100.0  # Scale if more than 100 requests per target per minute
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# -----------------------------------------------------------------------------
# Scheduled Scaling: Scale DOWN at Night (10 PM UTC)
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_scheduled_action" "scale_down_night" {
  name               = "proj2-scale-down-night"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(0 22 * * ? *)"  # 10 PM UTC daily

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

# -----------------------------------------------------------------------------
# Scheduled Scaling: Scale UP in Morning (8 AM UTC)
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_scheduled_action" "scale_up_morning" {
  name               = "proj2-scale-up-morning"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(0 8 * * ? *)"  # 8 AM UTC daily

  scalable_target_action {
    min_capacity = var.min_task_count
    max_capacity = var.max_task_count
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm for Scale-to-Zero Notification
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "service_scaled_to_zero" {
  alarm_name          = "proj2-service-scaled-to-zero"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "ECS service has scaled to zero tasks (scheduled night mode)"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.proj2_cluster.name
    ServiceName = aws_ecs_service.proj2_service.name
  }

  # Don't send notifications for this - it's expected behavior
  # alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-service-scaled-to-zero"
  }
}
