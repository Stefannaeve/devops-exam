# Declare a variable for the notification email
variable "notification_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}

# Assume the SQS queue is already defined elsewhere in your Terraform code
resource "aws_sqs_queue" "my_queue" {
  name = "my_queue"
  # Additional configuration for your SQS queue
}

# Create an SNS topic for the alarm to publish to
resource "aws_sns_topic" "alarm_topic" {
  name = "sqs_age_alarm_topic"
}

# Create an email subscription to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Define the CloudWatch alarm
resource "aws_cloudwatch_metric_alarm" "sqs_age_alarm" {
  alarm_name          = "${prefix}-OldestMessageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 15
  period              = 60

  metric_name = "ApproximateAgeOfOldestMessage"
  namespace   = var.prefix
  statistic   = "Maximum"

  dimensions = {
    QueueName = aws_sqs_queue.my_queue.name
  }

  alarm_description = "Alarm when the oldest message in the SQS queue exceeds the threshold age"
  alarm_actions     = [aws_sns_topic.alarm_topic.arn]
}

output "email_subscription_confirmation" {
  value = "An email has been sent to ${var.notification_email}"
}
