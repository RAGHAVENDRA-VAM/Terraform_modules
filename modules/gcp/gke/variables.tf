variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Cluster location (region for regional, zone for zonal)"
  type        = string
}

variable "network" {
  description = "VPC network self link"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self link"
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Secondary range name for pods"
  type        = string
  default     = null
}

variable "services_secondary_range_name" {
  description = "Secondary range name for services"
  type        = string
  default     = null
}

variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of authorized networks for master access"
  type        = list(map(string))
  default     = []
}

variable "release_channel" {
  description = "Release channel: RAPID, REGULAR, STABLE"
  type        = string
  default     = "REGULAR"
}

variable "min_master_version" {
  description = "Minimum master version"
  type        = string
  default     = null
}

variable "enable_http_load_balancing" {
  type    = bool
  default = true
}

variable "enable_horizontal_pod_autoscaling" {
  type    = bool
  default = true
}

variable "enable_network_policy" {
  type    = bool
  default = true
}

variable "node_pools" {
  description = "Map of node pool configurations"
  type        = map(any)
  default = {
    default = {
      machine_type       = "e2-medium"
      node_count         = 2
      enable_autoscaling = false
    }
  }
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}
