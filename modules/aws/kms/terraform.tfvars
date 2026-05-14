# =============================================================================
# terraform.tfvars — AWS KMS Module
# =============================================================================

alias                   = "dev-main"
description             = "Main encryption key for dev environment"
enable_key_rotation     = true
rotation_period_in_days = 365
deletion_window_in_days = 30
multi_region            = false

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
