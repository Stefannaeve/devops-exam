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

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${var.prefix}_LambdaS3Policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::pgr301-couch-explorers/*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_bedrock_policy" {
  name = "${var.prefix}_LambdaBedrockPolicy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_bedrock_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
  batch_size       = 5
}

output "lambda_function_name" {
  value = aws_lambda_function.sqs_lambda.function_name
}