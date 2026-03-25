resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix != null ? var.dns_prefix : var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    vnet_subnet_id      = lookup(var.default_node_pool, "subnet_id", null)
    os_disk_size_gb     = lookup(var.default_node_pool, "os_disk_size_gb", 30)
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = lookup(var.default_node_pool, "enable_auto_scaling", false)
    min_count           = lookup(var.default_node_pool, "enable_auto_scaling", false) ? lookup(var.default_node_pool, "min_count", 1) : null
    max_count           = lookup(var.default_node_pool, "enable_auto_scaling", false) ? lookup(var.default_node_pool, "max_count", 3) : null
    node_labels         = lookup(var.default_node_pool, "node_labels", {})
    tags                = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  azure_policy_enabled             = var.azure_policy_enabled
  http_application_routing_enabled = false

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_secret_store_csi ? [1] : []
    content {
      secret_rotation_enabled = true
    }
  }

  tags = merge({ Name = var.cluster_name }, var.tags)
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = lookup(each.value, "node_count", 1)
  vnet_subnet_id        = lookup(each.value, "subnet_id", null)
  os_disk_size_gb       = lookup(each.value, "os_disk_size_gb", 30)
  enable_auto_scaling   = lookup(each.value, "enable_auto_scaling", false)
  min_count             = lookup(each.value, "enable_auto_scaling", false) ? lookup(each.value, "min_count", 1) : null
  max_count             = lookup(each.value, "enable_auto_scaling", false) ? lookup(each.value, "max_count", 3) : null
  node_labels           = lookup(each.value, "node_labels", {})
  node_taints           = lookup(each.value, "node_taints", [])
  mode                  = lookup(each.value, "mode", "User")
  tags                  = var.tags
}
