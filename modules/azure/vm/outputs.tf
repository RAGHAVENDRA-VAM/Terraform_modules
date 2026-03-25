output "vm_id" {
  description = "Virtual machine ID"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].id, null) : try(azurerm_windows_virtual_machine.this[0].id, null)
}

output "private_ip" {
  description = "Private IP address"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  description = "Public IP address"
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "nic_id" {
  description = "Network interface ID"
  value       = azurerm_network_interface.this.id
}

output "identity_principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].identity[0].principal_id, null) : try(azurerm_windows_virtual_machine.this[0].identity[0].principal_id, null)
}
