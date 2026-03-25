output "service_account_emails" {
  description = "Map of service account emails"
  value       = { for k, v in google_service_account.this : k => v.email }
}

output "service_account_ids" {
  description = "Map of service account IDs"
  value       = { for k, v in google_service_account.this : k => v.id }
}

output "custom_role_ids" {
  description = "Map of custom role IDs"
  value       = { for k, v in google_project_iam_custom_role.this : k => v.id }
}
