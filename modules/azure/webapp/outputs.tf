output "web_app_id" {
  description = "Web app resource ID"
  value       = local.web_app_id
}

output "web_app_name" {
  description = "Web app name"
  value       = var.app_name
}

output "default_hostname" {
  description = "Default hostname of the web app"
  value       = local.web_app_hostname
}

output "default_site_url" {
  description = "Default HTTPS URL of the web app"
  value       = "https://${local.web_app_hostname}"
}

output "service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.this.id
}

output "identity_principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = try(local.web_app_identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "System-assigned managed identity tenant ID"
  value       = try(local.web_app_identity[0].tenant_id, null)
}

output "linux_slot_hostnames" {
  description = "Map of Linux deployment slot hostnames"
  value       = { for k, v in azurerm_linux_web_app_slot.this : k => v.default_hostname }
}

output "windows_slot_hostnames" {
  description = "Map of Windows deployment slot hostnames"
  value       = { for k, v in azurerm_windows_web_app_slot.this : k => v.default_hostname }
}

output "custom_hostname_bindings" {
  description = "Map of custom hostname bindings"
  value       = { for k, v in azurerm_app_service_custom_hostname_binding.this : k => v.id }
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses of the web app"
  value       = var.os_type == "Linux" ? try(azurerm_linux_web_app.this[0].outbound_ip_addresses, null) : try(azurerm_windows_web_app.this[0].outbound_ip_addresses, null)
}

output "possible_outbound_ip_addresses" {
  description = "All possible outbound IP addresses"
  value       = var.os_type == "Linux" ? try(azurerm_linux_web_app.this[0].possible_outbound_ip_addresses, null) : try(azurerm_windows_web_app.this[0].possible_outbound_ip_addresses, null)
}
