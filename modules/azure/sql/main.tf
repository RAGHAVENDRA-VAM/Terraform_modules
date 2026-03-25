resource "azurerm_mssql_server" "this" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = var.aad_admin_login
    object_id      = var.aad_admin_object_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge({ Name = var.server_name }, var.tags)
}

resource "azurerm_mssql_database" "this" {
  for_each = var.databases

  name         = each.key
  server_id    = azurerm_mssql_server.this.id
  collation    = lookup(each.value, "collation", "SQL_Latin1_General_CP1_CI_AS")
  license_type = lookup(each.value, "license_type", "LicenseIncluded")
  sku_name     = lookup(each.value, "sku_name", "S1")
  max_size_gb  = lookup(each.value, "max_size_gb", 4)
  zone_redundant = lookup(each.value, "zone_redundant", false)

  dynamic "short_term_retention_policy" {
    for_each = lookup(each.value, "backup_retention_days", null) != null ? [1] : []
    content {
      retention_days           = each.value.backup_retention_days
      backup_interval_in_hours = lookup(each.value, "backup_interval_in_hours", 12)
    }
  }

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

resource "azurerm_mssql_virtual_network_rule" "this" {
  for_each  = var.vnet_rules
  name      = each.key
  server_id = azurerm_mssql_server.this.id
  subnet_id = each.value
}

resource "azurerm_mssql_server_transparent_data_encryption" "this" {
  server_id        = azurerm_mssql_server.this.id
  key_vault_key_id = var.tde_key_vault_key_id
}
