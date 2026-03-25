variable "vnet_name" {
  description = "Virtual network name"
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

variable "create_resource_group" {
  description = "Create the resource group"
  type        = bool
  default     = false
}

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Map of subnet configurations"
  type        = map(any)
  default     = {}
}

variable "create_nat_gateway" {
  description = "Create a NAT Gateway"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
