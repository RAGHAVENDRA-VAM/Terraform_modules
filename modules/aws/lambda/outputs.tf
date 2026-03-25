output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}

output "function_url" {
  description = "Lambda function URL"
  value       = try(aws_lambda_function_url.this[0].function_url, null)
}

output "role_arn" {
  description = "Lambda IAM role ARN"
  value       = try(aws_iam_role.lambda[0].arn, var.role_arn)
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.lambda.name
}
