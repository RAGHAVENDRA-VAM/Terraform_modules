output "global_ip_address" {
  description = "Global IP address"
  value       = try(google_compute_global_address.this[0].address, null)
}

output "regional_ip_address" {
  description = "Regional IP address"
  value       = try(google_compute_address.this[0].address, null)
}

output "url_map_id" {
  description = "URL map ID"
  value       = google_compute_url_map.this.id
}

output "backend_service_ids" {
  description = "Map of backend service IDs"
  value       = { for k, v in google_compute_backend_service.this : k => v.id }
}
