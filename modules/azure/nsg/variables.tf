variable "nsg_name" {
  description = "NSG name"
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

variable "security_rules" {
  description = "Map of security rules"
  type        = map(any)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with this NSG"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
