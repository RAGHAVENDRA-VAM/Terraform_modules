# variables.tf

variable "app_name" {
  description = "Web app name"
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

variable "sku_name" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "os_type" {
  description = "Linux or Windows"
  type        = string
  default     = "Linux"
}

variable "worker_count" {
  description = "Worker count"
  type        = number
  default     = 1
}

variable "always_on" {
  description = "Always on"
  type        = bool
  default     = true
}

variable "client_affinity_enabled" {
  description = "Client affinity"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = null
}

variable "application_stack" {
  description = "Runtime stack"
  type        = map(string)
  default     = {}
}

variable "app_settings" {
  description = "Application settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}