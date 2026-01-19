# CloudWatch Dashboard for proj2 Application Monitoring

resource "aws_cloudwatch_dashboard" "proj2" {
  dashboard_name = "proj2-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: Key Metrics Summary
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# Proj2 ECS Fargate Application Dashboard"
        }
      },

      # Row 2: Request Count and Response Time
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "Request Count"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, { stat = "Sum", period = 60 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "Response Time (seconds)"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, "TargetGroup", aws_lb_target_group.proj2_tg.arn_suffix, { stat = "Average", period = 60 }],
            ["...", { stat = "p99", period = 60, label = "p99" }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "Healthy vs Unhealthy Hosts"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, "TargetGroup", aws_lb_target_group.proj2_tg.arn_suffix, { stat = "Average", period = 60, color = "#2ca02c" }],
            [".", "UnHealthyHostCount", ".", ".", ".", ".", { stat = "Average", period = 60, color = "#d62728" }]
          ]
          view = "timeSeries"
        }
      },

      # Row 3: Error Rates
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "HTTP Status Codes"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, "TargetGroup", aws_lb_target_group.proj2_tg.arn_suffix, { stat = "Sum", period = 60, color = "#2ca02c", label = "2XX Success" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", ".", ".", { stat = "Sum", period = 60, color = "#ff7f0e", label = "4XX Client Error" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", ".", ".", { stat = "Sum", period = 60, color = "#d62728", label = "5XX Server Error" }],
            [".", "HTTPCode_ELB_5XX_Count", ".", ".", { stat = "Sum", period = 60, color = "#9467bd", label = "ALB 5XX" }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "Error Rate (%)"
          region = var.aws_region
          metrics = [
            [{ expression = "(m2+m3)/(m1+m2+m3)*100", label = "Error Rate %", id = "e1" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, "TargetGroup", aws_lb_target_group.proj2_tg.arn_suffix, { stat = "Sum", period = 60, id = "m1", visible = false }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", ".", ".", { stat = "Sum", period = 60, id = "m2", visible = false }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", ".", ".", { stat = "Sum", period = 60, id = "m3", visible = false }]
          ]
          view = "timeSeries"
        }
      },

      # Row 4: ECS Metrics
      {
        type   = "metric"
        x      = 0
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU Utilization (%)"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.proj2_cluster.name, "ServiceName", aws_ecs_service.proj2_service.name, { stat = "Average", period = 60 }],
            ["...", { stat = "Maximum", period = 60, label = "Max" }]
          ]
          view = "timeSeries"
          annotations = {
            horizontal = [
              { value = var.cpu_threshold, label = "Alarm Threshold", color = "#d62728" }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "ECS Memory Utilization (%)"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.proj2_cluster.name, "ServiceName", aws_ecs_service.proj2_service.name, { stat = "Average", period = 60 }],
            ["...", { stat = "Maximum", period = 60, label = "Max" }]
          ]
          view = "timeSeries"
          annotations = {
            horizontal = [
              { value = var.memory_threshold, label = "Alarm Threshold", color = "#d62728" }
            ]
          }
        }
      },

      # Row 5: Running Tasks and Alarm Status
      {
        type   = "metric"
        x      = 0
        y      = 19
        width  = 8
        height = 6
        properties = {
          title  = "ECS Running Tasks"
          region = var.aws_region
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.proj2_cluster.name, "ServiceName", aws_ecs_service.proj2_service.name, { stat = "Average", period = 60 }]
          ]
          view   = "singleValue"
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 19
        width  = 8
        height = 6
        properties = {
          title  = "Active Connections"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, { stat = "Sum", period = 60 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 19
        width  = 8
        height = 6
        properties = {
          title  = "New Connections per Second"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "NewConnectionCount", "LoadBalancer", aws_lb.proj2_alb.arn_suffix, { stat = "Sum", period = 60 }]
          ]
          view = "timeSeries"
        }
      },

      # Row 6: Logs Widget
      {
        type   = "log"
        x      = 0
        y      = 25
        width  = 24
        height = 6
        properties = {
          title  = "Recent Application Logs"
          region = var.aws_region
          query  = "SOURCE '/ecs/proj2-app' | fields @timestamp, @message | sort @timestamp desc | limit 50"
        }
      }
    ]
  })
}
