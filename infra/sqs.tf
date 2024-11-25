resource "aws_sqs_queue" "sqs_queue" {
  name = "${var.prefix}_sqs_queue"
  // Has to be higher than function timeout
  visibility_timeout_seconds = 65
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": aws_sqs_queue.sqs_queue.arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "sqs_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sqs_lambda.function_name}"
  retention_in_days = 60
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy = false
  }
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.id
}