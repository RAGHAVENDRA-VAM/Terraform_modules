output "app_id" {
  description = "App Engine application ID"
  value       = try(google_app_engine_application.this[0].id, null)
}

output "app_url" {
  description = "Default App Engine URL"
  value       = try("https://${var.project_id}.appspot.com", null)
}

output "service_url" {
  description = "Service-specific URL"
  value       = var.service_name == "default" ? "https://${var.project_id}.appspot.com" : "https://${var.service_name}-dot-${var.project_id}.appspot.com"
}

output "version_url" {
  description = "Version-specific URL"
  value       = "https://${var.version_id}-dot-${var.service_name}-dot-${var.project_id}.appspot.com"
}

output "standard_version_id" {
  description = "Standard environment version ID"
  value       = try(google_app_engine_standard_app_version.this[0].version_id, null)
}

output "flexible_version_id" {
  description = "Flexible environment version ID"
  value       = try(google_app_engine_flexible_app_version.this[0].version_id, null)
}

output "vpc_connector_id" {
  description = "VPC Access Connector ID"
  value       = try(google_vpc_access_connector.this[0].id, null)
}

output "custom_domain_resource_records" {
  description = "DNS records required for custom domain verification"
  value = {
    for k, v in google_app_engine_domain_mapping.this :
    k => v.resource_records
  }
}
