variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type        = map(any)
  default = {
    vm_size    = "Standard_D2s_v3"
    node_count = 2
  }
}

variable "additional_node_pools" {
  description = "Map of additional node pool configurations"
  type        = map(any)
  default     = {}
}

variable "network_plugin" {
  description = "Network plugin: azure or kubenet"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy: azure or calico"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.100.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.100.0.10"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring"
  type        = string
  default     = null
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy addon"
  type        = bool
  default     = false
}

variable "enable_secret_store_csi" {
  description = "Enable Secret Store CSI driver"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
