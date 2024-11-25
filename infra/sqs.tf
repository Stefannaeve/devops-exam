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

#### Absolute chaos code based on problems when i changed the prefix, thought you might find this fun to look at
#### I ended up importing the group with "terraform import", that fixed the log group problem

# This was a weird one, i had a lot of problems with creating the aws cloudwatch
# When i changed the input for the variable prefix
# So i tried a lot to fix it, including trying to make lambda function dependant
# On the creation of the log group, so it might destroy then build it again
# So aws wouldnt make it. That did not work, so after a lot of searching i found
# This method to be the one that actually worked. This might never have been
# A problem if i just stuck to the prefix i originally made lmfao
/*
resource "null_resource" "set_log_retention" {
  # Ensure this runs after the Lambda function is created
  depends_on = [aws_lambda_function.sqs_lambda]

  provisioner "local-exec" {
    command = "aws logs put-retention-policy --log-group-name '/aws/lambda/${aws_lambda_function.sqs_lambda.function_name}' --retention-in-days 60"
  }
}
*/