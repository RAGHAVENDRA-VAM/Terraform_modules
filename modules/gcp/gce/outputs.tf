output "instance_ids" {
  description = "List of instance IDs"
  value       = google_compute_instance.this[*].id
}

output "instance_self_links" {
  description = "List of instance self links"
  value       = google_compute_instance.this[*].self_link
}

output "internal_ips" {
  description = "List of internal IP addresses"
  value       = [for i in google_compute_instance.this : i.network_interface[0].network_ip]
}

output "external_ips" {
  description = "List of external IP addresses"
  value       = [for i in google_compute_instance.this : try(i.network_interface[0].access_config[0].nat_ip, null)]
}
