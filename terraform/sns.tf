# SNS Topic for CloudWatch Alarm Notifications
resource "aws_sns_topic" "alerts" {
  name = "proj2-alerts"

  tags = {
    Name = "proj2-alerts"
  }
}

# SNS Topic Policy - Allow CloudWatch to publish
resource "aws_sns_topic_policy" "alerts_policy" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudWatchAlarms"
        Effect    = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# Email subscription for alerts
# Note: After terraform apply, you must confirm the subscription via email
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
