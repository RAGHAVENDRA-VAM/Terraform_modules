# =============================================================================
# terraform.tfvars — AWS CloudWatch Module
# =============================================================================

log_groups = {
  "/app/dev/api" = {
    retention_in_days = 14
  }
  "/app/dev/worker" = {
    retention_in_days = 7
  }
}

metric_alarms = {
  high-cpu = {
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    threshold           = 80
    description         = "Alert when CPU exceeds 80%"
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
