output "lb_id" {
  description = "Load balancer ID"
  value       = azurerm_lb.this.id
}

output "backend_pool_id" {
  description = "Backend address pool ID"
  value       = azurerm_lb_backend_address_pool.this.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "frontend_ip_configuration" {
  description = "Frontend IP configuration name"
  value       = "frontend"
}
