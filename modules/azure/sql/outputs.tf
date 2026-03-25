output "server_id" {
  description = "SQL server ID"
  value       = azurerm_mssql_server.this.id
}

output "server_fqdn" {
  description = "SQL server FQDN"
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_ids" {
  description = "Map of database IDs"
  value       = { for k, v in azurerm_mssql_database.this : k => v.id }
}

output "server_identity_principal_id" {
  description = "SQL server system-assigned identity principal ID"
  value       = azurerm_mssql_server.this.identity[0].principal_id
}
