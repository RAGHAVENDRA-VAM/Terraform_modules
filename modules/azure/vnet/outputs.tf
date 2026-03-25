output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "resource_group_name" {
  description = "Resource group name"
  value       = local.resource_group_name
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = try(azurerm_nat_gateway.this[0].id, null)
}

output "nsg_ids" {
  description = "Map of NSG IDs"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}
