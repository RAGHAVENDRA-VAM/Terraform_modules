variable "key_vault_name" {
  description = "Key Vault name (globally unique, 3-24 chars)"
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
  description = "SKU: standard or premium"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days (7-90)"
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Use RBAC instead of access policies"
  type        = bool
  default     = true
}

variable "network_acls_default_action" {
  description = "Default network action: Allow or Deny"
  type        = string
  default     = "Deny"
}

variable "network_acls_bypass" {
  description = "Services that bypass network rules"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "network_acls_ip_rules" {
  description = "Allowed IP rules"
  type        = list(string)
  default     = []
}

variable "network_acls_subnet_ids" {
  description = "Allowed subnet IDs"
  type        = list(string)
  default     = []
}

variable "access_policies" {
  description = "Map of access policies (used when RBAC is disabled)"
  type        = map(any)
  default     = {}
}

variable "secrets" {
  description = "Map of secrets to create"
  type        = map(any)
  default     = {}
  sensitive   = true
}

variable "keys" {
  description = "Map of keys to create"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
