output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "identity_principal_id" {
  description = "System-assigned identity principal ID"
  value       = azurerm_storage_account.this.identity[0].principal_id
}

output "container_ids" {
  description = "Map of container IDs"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}
