# =============================================================================
# terraform.tfvars — AWS S3 Module
# =============================================================================

bucket_name        = "dev-app-data-123456789012"
versioning_enabled = true
force_destroy      = false

lifecycle_rules = [
  {
    id      = "transition-to-ia"
    transitions = [
      { days = 30, storage_class = "STANDARD_IA" }
    ]
    noncurrent_version_expiration_days = 90
  }
]

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
