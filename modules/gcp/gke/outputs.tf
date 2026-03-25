output "cluster_id" {
  description = "GKE cluster ID"
  value       = google_container_cluster.this.id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "node_pool_ids" {
  description = "Map of node pool IDs"
  value       = { for k, v in google_container_node_pool.this : k => v.id }
}
