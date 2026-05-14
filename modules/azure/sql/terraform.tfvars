# =============================================================================
# terraform.tfvars — Azure SQL Module
# =============================================================================

server_name                  = "dev-sqlserver-abc123"
location                     = "East US"
resource_group_name          = "rg-dev"
server_version               = "12.0"
administrator_login          = "sqladmin"
administrator_login_password = "Change_Me_Before_Apply_123!"   # use TF_VAR_administrator_login_password

databases = {
  appdb = {
    sku_name    = "S1"
    max_size_gb = 10
    backup_retention_days = 7
  }
}

firewall_rules = {
  allow-azure-services = {
    start_ip = "0.0.0.0"
    end_ip   = "0.0.0.0"
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
