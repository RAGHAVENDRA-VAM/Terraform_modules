# =============================================================================
# terraform.tfvars — AWS SNS Module
# =============================================================================

name         = "dev-alerts"
display_name = "Dev Alerts"
fifo_topic   = false

subscriptions = {
  email-ops = {
    protocol = "email"
    endpoint = "ops-team@example.com"
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
