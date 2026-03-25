data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku_name
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  enable_rbac_authorization   = var.enable_rbac_authorization

  network_acls {
    default_action             = var.network_acls_default_action
    bypass                     = var.network_acls_bypass
    ip_rules                   = var.network_acls_ip_rules
    virtual_network_subnet_ids = var.network_acls_subnet_ids
  }

  tags = merge({ Name = var.key_vault_name }, var.tags)
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each = var.enable_rbac_authorization ? {} : var.access_policies

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  key_permissions         = lookup(each.value, "key_permissions", [])
  secret_permissions      = lookup(each.value, "secret_permissions", [])
  certificate_permissions = lookup(each.value, "certificate_permissions", [])
}

resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name         = each.key
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id
  content_type = lookup(each.value, "content_type", null)
  tags         = var.tags
}

resource "azurerm_key_vault_key" "this" {
  for_each = var.keys

  name         = each.key
  key_vault_id = azurerm_key_vault.this.id
  key_type     = lookup(each.value, "key_type", "RSA")
  key_size     = lookup(each.value, "key_size", 2048)
  key_opts     = lookup(each.value, "key_opts", ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"])
  tags         = var.tags
}
