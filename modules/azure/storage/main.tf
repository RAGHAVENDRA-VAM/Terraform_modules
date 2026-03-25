resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = var.shared_access_key_enabled

  dynamic "blob_properties" {
    for_each = var.enable_versioning || var.enable_soft_delete ? [1] : []
    content {
      versioning_enabled = var.enable_versioning
      dynamic "delete_retention_policy" {
        for_each = var.enable_soft_delete ? [1] : []
        content {
          days = var.soft_delete_retention_days
        }
      }
      dynamic "container_delete_retention_policy" {
        for_each = var.enable_soft_delete ? [1] : []
        content {
          days = var.soft_delete_retention_days
        }
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = lookup(network_rules.value, "default_action", "Deny")
      bypass                     = lookup(network_rules.value, "bypass", ["AzureServices"])
      ip_rules                   = lookup(network_rules.value, "ip_rules", [])
      virtual_network_subnet_ids = lookup(network_rules.value, "subnet_ids", [])
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge({ Name = var.storage_account_name }, var.tags)
}

resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = each.key
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = lookup(each.value, "access_type", "private")
}

resource "azurerm_storage_queue" "this" {
  for_each             = var.queues
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_storage_table" "this" {
  for_each             = var.tables
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_storage_share" "this" {
  for_each             = var.file_shares
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
  quota                = lookup(each.value, "quota_gb", 50)
}
