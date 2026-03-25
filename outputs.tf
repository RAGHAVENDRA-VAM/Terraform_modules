# ─── AWS Outputs ─────────────────────────────────────────────────────────────

output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = try(module.aws_vpc[0].vpc_id, null)
}

output "aws_public_subnet_ids" {
  description = "AWS public subnet IDs"
  value       = try(module.aws_vpc[0].public_subnet_ids, [])
}

output "aws_private_subnet_ids" {
  description = "AWS private subnet IDs"
  value       = try(module.aws_vpc[0].private_subnet_ids, [])
}

output "aws_rds_endpoint" {
  description = "AWS RDS endpoint"
  value       = try(module.aws_rds[0].db_endpoint, null)
}

output "aws_alb_dns_name" {
  description = "AWS ALB DNS name"
  value       = try(module.aws_alb[0].alb_dns_name, null)
}

output "aws_eks_cluster_endpoint" {
  description = "AWS EKS cluster endpoint"
  value       = try(module.aws_eks[0].cluster_endpoint, null)
}

output "aws_s3_bucket_arn" {
  description = "AWS S3 bucket ARN"
  value       = try(module.aws_s3_app[0].bucket_arn, null)
}

output "aws_kms_key_arn" {
  description = "AWS KMS key ARN"
  value       = try(module.aws_kms[0].key_arn, null)
}

# ─── Azure Outputs ───────────────────────────────────────────────────────────

output "azure_vnet_id" {
  description = "Azure VNet ID"
  value       = try(module.azure_vnet[0].vnet_id, null)
}

output "azure_aks_cluster_endpoint" {
  description = "Azure AKS cluster endpoint"
  value       = try(module.azure_aks[0].cluster_endpoint, null)
}

output "azure_key_vault_uri" {
  description = "Azure Key Vault URI"
  value       = try(module.azure_keyvault[0].key_vault_uri, null)
}

output "azure_storage_primary_endpoint" {
  description = "Azure Storage primary blob endpoint"
  value       = try(module.azure_storage[0].primary_blob_endpoint, null)
}

output "azure_log_analytics_workspace_id" {
  description = "Azure Log Analytics workspace ID"
  value       = try(module.azure_monitor[0].log_analytics_workspace_id, null)
}

# ─── GCP Outputs ─────────────────────────────────────────────────────────────

output "gcp_network_name" {
  description = "GCP VPC network name"
  value       = try(module.gcp_vpc[0].network_name, null)
}

output "gcp_gke_cluster_endpoint" {
  description = "GCP GKE cluster endpoint"
  value       = try(module.gcp_gke[0].cluster_endpoint, null)
  sensitive   = true
}

output "gcp_cloudsql_connection_name" {
  description = "GCP Cloud SQL connection name"
  value       = try(module.gcp_cloudsql[0].instance_connection_name, null)
}

output "gcp_storage_bucket_url" {
  description = "GCP Storage bucket URL"
  value       = try(module.gcp_storage[0].bucket_url, null)
}

output "gcp_service_account_emails" {
  description = "GCP service account emails"
  value       = try(module.gcp_iam[0].service_account_emails, {})
}

output "gcp_pubsub_topic_ids" {
  description = "GCP Pub/Sub topic IDs"
  value       = try(module.gcp_pubsub[0].topic_ids, {})
}
