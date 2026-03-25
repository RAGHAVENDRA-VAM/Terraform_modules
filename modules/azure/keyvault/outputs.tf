output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "secret_ids" {
  description = "Map of secret IDs"
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.id }
}

output "key_ids" {
  description = "Map of key IDs"
  value       = { for k, v in azurerm_key_vault_key.this : k => v.id }
}
