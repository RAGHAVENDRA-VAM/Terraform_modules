# =============================================================================
# terraform.tfvars — Azure NSG Module
# =============================================================================

nsg_name            = "dev-web-nsg"
location            = "East US"
resource_group_name = "rg-dev"
subnet_ids          = []

security_rules = {
  allow-http = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTP"
  }
  allow-https = {
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS"
  }
  deny-all-inbound = {
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Deny all other inbound"
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
