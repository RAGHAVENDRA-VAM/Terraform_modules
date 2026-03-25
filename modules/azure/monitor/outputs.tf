output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = try(azurerm_log_analytics_workspace.this[0].id, null)
}

output "log_analytics_workspace_key" {
  description = "Log Analytics workspace primary key"
  value       = try(azurerm_log_analytics_workspace.this[0].primary_shared_key, null)
  sensitive   = true
}

output "action_group_ids" {
  description = "Map of action group IDs"
  value       = { for k, v in azurerm_monitor_action_group.this : k => v.id }
}
