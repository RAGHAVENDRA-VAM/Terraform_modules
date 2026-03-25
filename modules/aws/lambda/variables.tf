variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "description" {
  description = "Lambda function description"
  type        = string
  default     = ""
}

variable "create_role" {
  description = "Create an IAM role for the Lambda function"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "Existing IAM role ARN (when create_role = false)"
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "Additional managed policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "handler" {
  description = "Lambda handler (file.function)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda memory in MB"
  type        = number
  default     = 128
}

variable "architectures" {
  description = "Lambda architectures"
  type        = list(string)
  default     = ["x86_64"]
}

variable "filename" {
  description = "Path to the deployment package"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket for deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key for deployment package"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "tracing_mode" {
  description = "X-Ray tracing mode: PassThrough or Active"
  type        = string
  default     = "Active"
}

variable "dead_letter_target_arn" {
  description = "SQS/SNS ARN for dead letter queue"
  type        = string
  default     = null
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions (-1 for unreserved)"
  type        = number
  default     = -1
}

variable "kms_key_arn" {
  description = "KMS key ARN for environment variable encryption"
  type        = string
  default     = null
}

variable "create_function_url" {
  description = "Create a Lambda function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Function URL auth type: NONE or AWS_IAM"
  type        = string
  default     = "AWS_IAM"
}

variable "function_url_cors" {
  description = "CORS configuration for function URL"
  type        = map(any)
  default     = null
}

variable "event_source_mappings" {
  description = "Map of event source mappings"
  type        = map(any)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  type    = map(string)
  default = {}
}
