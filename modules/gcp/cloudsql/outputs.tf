output "instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.this.name
}

output "instance_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.this.connection_name
}

output "private_ip_address" {
  description = "Private IP address"
  value       = google_sql_database_instance.this.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address"
  value       = google_sql_database_instance.this.public_ip_address
}

output "database_names" {
  description = "List of database names"
  value       = [for k, v in google_sql_database.this : v.name]
}

output "replica_connection_names" {
  description = "Map of replica connection names"
  value       = { for k, v in google_sql_database_instance.replicas : k => v.connection_name }
}
