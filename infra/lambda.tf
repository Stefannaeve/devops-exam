resource "aws_iam_role" "lambda_exec_role" {
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })

  name = "${var.prefix}_lambda_exec_role"
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "${var.prefix}_LambdaSQSPolicy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sqs:*"
        ],
        "Resource": aws_sqs_queue.sqs_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${var.prefix}_LambdaS3Policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": "arn:aws:s3:::pgr301-couch-explorers/*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock_full_access" {
  role = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

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
        ]
        "Resource": aws_sqs_queue.sqs_queue.arn
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "lambda_sqs.py"
  output_path = "lambda_function_zip.zip"
}

resource "aws_lambda_function" "sqs_lambda" {
  function_name = "${var.prefix}_sqs_lambda_function"
  runtime       = "python3.8"
  handler       = "lambda_sqs.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  
  timeout = 60

  filename          = data.archive_file.lambda_zip.output_path
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = "DEBUG"
      QUEUE_URL = aws_sqs_queue.sqs_queue.id
      bucket_name   = var.bucket_name
      bucket_folder = var.bucket_folder
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  enabled          = true
}


# This was a weird one, i had a lot of problems with creating the aws cloudwatch
# When i changed the input for the variable prefix
# So i tried a lot to fix it, including trying to make lambda function dependant
# On the creation of the log group, so it might destroy then build it again
# So aws wouldnt make it. That did not work, so after a lot of searching i found
# This method to be the one that actually worked. This might never have been
# A problem if i just stuck to the prefix i originally made lmfao
resource "null_resource" "set_log_retention" {
  # Ensure this runs after the Lambda function is created
  depends_on = [aws_lambda_function.sqs_lambda]

  provisioner "local-exec" {
    command = "aws logs put-retention-policy --log-group-name '/aws/lambda/${aws_lambda_function.sqs_lambda.function_name}' --retention-in-days 60"
  }
}

/*
resource "aws_cloudwatch_log_group" "sqs_log_group" {
  name              = "/aws/lambda/${var.prefix}_sqs_lambda_function"
  retention_in_days = 60
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy = false
  }
}
*/

output "lambda_function_name" {
  value = aws_lambda_function.sqs_lambda.function_name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.id
}
