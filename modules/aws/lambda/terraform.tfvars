# =============================================================================
# terraform.tfvars — AWS Lambda Module
# =============================================================================

function_name = "dev-event-processor"
description   = "Processes events from SQS"
handler       = "index.handler"
runtime       = "python3.12"
timeout       = 30
memory_size   = 128
architectures = ["x86_64"]

filename         = "lambda.zip"
source_code_hash = null

environment_variables = {
  ENV       = "dev"
  LOG_LEVEL = "INFO"
}

create_role            = true
additional_policy_arns = []
tracing_mode           = "Active"
log_retention_days     = 14

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
