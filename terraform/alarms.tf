# CloudWatch Alarms for ECS and ALB Monitoring

# =============================================================================
# ECS CPU Utilization Alarm
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "proj2-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "ECS CPU utilization is above ${var.cpu_threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.proj2_cluster.name
    ServiceName = aws_ecs_service.proj2_service.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-ecs-cpu-high"
  }
}

# =============================================================================
# ECS Memory Utilization Alarm
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "proj2-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "ECS Memory utilization is above ${var.memory_threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.proj2_cluster.name
    ServiceName = aws_ecs_service.proj2_service.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-ecs-memory-high"
  }
}

# =============================================================================
# ALB 5XX Error Rate Alarm
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "proj2-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is returning 5XX errors (more than 10 in 1 minute)"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.proj2_alb.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-alb-5xx-errors"
  }
}

# =============================================================================
# ALB Target 5XX Error Rate Alarm (from ECS tasks)
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx_errors" {
  alarm_name          = "proj2-target-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "ECS targets are returning 5XX errors (more than 5 in 1 minute)"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.proj2_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.proj2_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-target-5xx-errors"
  }
}

# =============================================================================
# ALB Unhealthy Host Count Alarm
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "proj2-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "There are unhealthy targets in the target group"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.proj2_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.proj2_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-unhealthy-hosts"
  }
}

# =============================================================================
# ALB High Response Time Alarm
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "proj2-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "ALB average response time is above 2 seconds"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.proj2_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.proj2_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-high-latency"
  }
}

# =============================================================================
# No Healthy Hosts Alarm (Critical)
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "no_healthy_hosts" {
  alarm_name          = "proj2-no-healthy-hosts-CRITICAL"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "CRITICAL: No healthy targets available - service is DOWN"
  treat_missing_data  = "breaching"

  dimensions = {
    LoadBalancer = aws_lb.proj2_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.proj2_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "proj2-no-healthy-hosts-CRITICAL"
  }
}
