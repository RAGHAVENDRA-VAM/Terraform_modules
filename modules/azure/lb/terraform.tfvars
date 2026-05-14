# =============================================================================
# terraform.tfvars — Azure Load Balancer Module
# =============================================================================

lb_name             = "dev-lb"
location            = "East US"
resource_group_name = "rg-dev"
create_public_ip    = true

probes = {
  http-probe = {
    protocol     = "Http"
    port         = 80
    request_path = "/health"
  }
}

lb_rules = {
  http-rule = {
    protocol      = "Tcp"
    frontend_port = 80
    backend_port  = 80
    probe_name    = "http-probe"
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
