resource "aws_iam_role" "lambda" {
  count = var.create_role ? 1 : 0
  name  = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.create_role && var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = var.create_role ? toset(var.additional_policy_arns) : toset([])
  role       = aws_iam_role.lambda[0].name
  policy_arn = each.value
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = var.create_role ? aws_iam_role.lambda[0].arn : var.role_arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  architectures = var.architectures

  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions
  kms_key_arn                     = var.kms_key_arn

  tags = merge({ Name = var.function_name }, var.tags)
}

resource "aws_lambda_function_url" "this" {
  count              = var.create_function_url ? 1 : 0
  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_origins = lookup(cors.value, "allow_origins", ["*"])
      allow_methods = lookup(cors.value, "allow_methods", ["*"])
      allow_headers = lookup(cors.value, "allow_headers", ["*"])
    }
  }
}

resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.event_source_mappings

  event_source_arn  = each.value.event_source_arn
  function_name     = aws_lambda_function.this.arn
  starting_position = lookup(each.value, "starting_position", "LATEST")
  batch_size        = lookup(each.value, "batch_size", 10)
  enabled           = lookup(each.value, "enabled", true)
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}
