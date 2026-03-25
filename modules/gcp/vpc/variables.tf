variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
}

variable "routing_mode" {
  description = "Routing mode: REGIONAL or GLOBAL"
  type        = string
  default     = "REGIONAL"
}

variable "description" {
  description = "Network description"
  type        = string
  default     = "Managed by Terraform"
}

variable "subnets" {
  description = "Map of subnet configurations"
  type        = map(any)
  default     = {}
}

variable "create_nat" {
  description = "Create a Cloud NAT gateway"
  type        = bool
  default     = false
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type        = map(any)
  default     = {}
}
