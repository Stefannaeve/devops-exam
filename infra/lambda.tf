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
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  enabled          = true
}

resource "aws_cloudwatch_log_group" "sqs_log_group" {
  name              = "/aws/lambda/${var.prefix}_sqs_lambda_function"
  retention_in_days = 7
}

output "lambda_function_name" {
  value = aws_lambda_function.sqs_lambda.function_name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.id
}
