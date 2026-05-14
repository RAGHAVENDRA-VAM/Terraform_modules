# =============================================================================
# terraform.tfvars — Azure Storage Module
# =============================================================================

storage_account_name     = "devsa12345678"
location                 = "East US"
resource_group_name      = "rg-dev"
account_tier             = "Standard"
account_replication_type = "LRS"
account_kind             = "StorageV2"
access_tier              = "Hot"

shared_access_key_enabled  = false
enable_versioning          = true
enable_soft_delete         = true
soft_delete_retention_days = 7

containers = {
  app-data = { access_type = "private" }
  backups  = { access_type = "private" }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
