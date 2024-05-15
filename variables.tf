variable "bucket_name" {
  description = "bucket name"
  type        = string
  default     = "ami-bucket"
}

variable "bucket_key" {
  description = "bucket object key"
  type        = string
  default     = "ami.json"
}

variable "ami_file_path" {
  description = "ami file to upload"
  type        = string
  default     = "./ami_id/ami.json"
}

variable "lambda_name" {
  description = "lambda role name"
  type        = string
  default     = "compliance_role"
}

variable "lambda_actual_policy" {
  description = "lambda actual policy name"
  type        = string
  default     = "compliance_polic_actual"
}

variable "region" {
  description = "aws region"
  type        = string
  default     = "us-west-2"
}

variable "python_runtime" {
  description = "for lamda"
  type        = string
  default     = "python3.8"
}

variable "python_lambda_function_name" {
  description = "for lamda"
  type        = string
  default     = "python3.8"
}

variable "python_lambda_function_entry" {
  description = "for lamda"
  type        = string
  default     = "lambda_function.lambda_call"
}

variable "cloudwatch_schedule_event_rule_name" {
  description = "for cloudwatch"
  type        = string
  default     = "every-hour"
}

variable "cloudwatch_schedule_event_rule_descrip" {
  description = "for cloudwatch"
  type        = string
  default     = "run every hour"
}

variable "cloudwatch_schedule_expression" {
  description = "for cloudwatch"
  type        = string
  default     = "rate(1 hour)"
}

variable "lambda_permission_statement_id" {
  description = "lambda permission"
  type        = string
  default     = "AllowExecutionFromCloudWatch"
}

variable "lambda_permission_action" {
  description = "lambda permission"
  type        = string
  default     = "lambda:InvokeFunction"
}

variable "lambda_permission_principle" {
  description = "lambda permission"
  type        = string
  default     = "events.amazonaws.com"
}