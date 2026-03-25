variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "create_log_analytics_workspace" {
  description = "Create a Log Analytics workspace"
  type        = bool
  default     = true
}

variable "workspace_name" {
  description = "Log Analytics workspace name"
  type        = string
  default     = ""
}

variable "workspace_sku" {
  description = "Log Analytics workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "action_groups" {
  description = "Map of action groups"
  type        = map(any)
  default     = {}
}

variable "metric_alerts" {
  description = "Map of metric alerts"
  type        = map(any)
  default     = {}
}

variable "diagnostic_settings" {
  description = "Map of diagnostic settings"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
