# =============================================================================
# terraform.tfvars — Azure VNet Module
# =============================================================================

vnet_name             = "dev-vnet"
location              = "East US"
resource_group_name   = "rg-dev"
create_resource_group = true
address_space         = ["10.0.0.0/16"]

subnets = {
  public = {
    address_prefixes = ["10.0.1.0/24"]
    create_nsg       = true
  }
  private = {
    address_prefixes = ["10.0.11.0/24"]
    create_nsg       = true
  }
  aks = {
    address_prefixes = ["10.0.21.0/24"]
  }
}

create_nat_gateway = false

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
