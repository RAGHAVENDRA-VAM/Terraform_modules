variable "lb_name" {
  description = "Load balancer name"
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

variable "create_public_ip" {
  description = "Create a public IP for the LB"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID for internal LB"
  type        = string
  default     = null
}

variable "private_ip" {
  description = "Static private IP for internal LB"
  type        = string
  default     = null
}

variable "probes" {
  description = "Map of health probes"
  type        = map(any)
  default     = {}
}

variable "lb_rules" {
  description = "Map of LB rules"
  type        = map(any)
  default     = {}
}

variable "nat_rules" {
  description = "Map of NAT rules"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
