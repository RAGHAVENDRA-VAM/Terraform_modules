output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Kubernetes config"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
}

output "identity_principal_id" {
  description = "Cluster system-assigned identity principal ID"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "Kubelet identity object ID"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "node_resource_group" {
  description = "Auto-created node resource group"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}
