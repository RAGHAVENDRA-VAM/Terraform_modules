output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded certificate authority data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.this.version
}

output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_group_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = aws_iam_role.node_group.arn
}

output "node_group_ids" {
  description = "Map of node group IDs"
  value       = { for k, v in aws_eks_node_group.this : k => v.id }
}
