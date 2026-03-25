variable "namespace_name" {
  description = "Service Bus namespace name"
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

variable "sku" {
  description = "SKU: Basic, Standard, or Premium"
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Capacity units (Premium only: 1, 2, 4, 8, 16)"
  type        = number
  default     = 1
}

variable "zone_redundant" {
  description = "Enable zone redundancy (Premium only)"
  type        = bool
  default     = false
}

variable "queues" {
  description = "Map of queue configurations"
  type        = map(any)
  default     = {}
}

variable "topics" {
  description = "Map of topic configurations (with optional subscriptions)"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
