output "namespace_id" {
  description = "Service Bus namespace ID"
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_endpoint" {
  description = "Service Bus namespace endpoint"
  value       = azurerm_servicebus_namespace.this.endpoint
}

output "queue_ids" {
  description = "Map of queue IDs"
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
}

output "topic_ids" {
  description = "Map of topic IDs"
  value       = { for k, v in azurerm_servicebus_topic.this : k => v.id }
}

output "identity_principal_id" {
  description = "System-assigned identity principal ID"
  value       = azurerm_servicebus_namespace.this.identity[0].principal_id
}
