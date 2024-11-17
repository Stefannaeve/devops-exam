resource "aws_sns_topic" "alarm_topic" {
  name = "sqs_age_alarm_topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_age_alarm" {
  alarm_name          = "${var.prefix}-OldestMessageAlarm"
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
