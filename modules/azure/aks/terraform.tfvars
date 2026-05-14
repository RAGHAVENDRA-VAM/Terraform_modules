# =============================================================================
# terraform.tfvars — Azure AKS Module
# =============================================================================

cluster_name        = "dev-aks"
location            = "East US"
resource_group_name = "rg-dev"
kubernetes_version  = null
dns_prefix          = "dev-aks"

default_node_pool = {
  vm_size             = "Standard_D2s_v3"
  node_count          = 2
  os_disk_size_gb     = 30
  enable_auto_scaling = true
  min_count           = 1
  max_count           = 4
}

additional_node_pools = {}

network_plugin = "azure"
network_policy = "azure"
service_cidr   = "10.100.0.0/16"
dns_service_ip = "10.100.0.10"

azure_policy_enabled    = false
enable_secret_store_csi = false

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
