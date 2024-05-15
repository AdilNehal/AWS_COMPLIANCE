resource "aws_s3_bucket" "ami_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.ami_bucket.bucket
  key    = var.bucket_key
  source = file("${var.ami_file_path}")
}

resource "aws_iam_role" "lambda_python_role" {
  name = var.lambda_name
  #lambda take this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_python_role.name
  # IAM > Policies > search AWSLambdaBasicExecutionRole
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_actual_policy" {
  name   = var.lambda_actual_policy
  role   = aws_iam_role.lambda_python_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "s3:GetObject",
          "ses:SendEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  #absolute path
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "compliance_python_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.python_lambda_function_name
  role             = aws_iam_role.lambda_python_role.arn
  handler          = var.python_lambda_function_entry
  runtime          = var.python_runtime
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.ami_bucket.bucket
      S3_KEY    = var.bucket_key
    }
  }
}

resource "aws_cloudwatch_event_rule" "run_every_hour" {
  name        = var.cloudwatch_schedule_event_rule_name
  description = var.cloudwatch_schedule_event_rule_descrip
  schedule_expression = var.cloudwatch_schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.run_every_hour.name
  arn = aws_lambda_function.compliance_python_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = var.lambda_permission_statement_id
  action        = var.lambda_permission_action
  function_name = aws_lambda_function.compliance_python_lambda.function_name
  principal     = var.lambda_permission_principle
  source_arn    = aws_cloudwatch_event_rule.run_every_hour.arn
}