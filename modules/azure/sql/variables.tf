variable "server_name" {
  description = "SQL server name (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "server_version" {
  description = "SQL server version"
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "SQL administrator login"
  type        = string
}

variable "administrator_login_password" {
  description = "SQL administrator password"
  type        = string
  sensitive   = true
}

variable "aad_admin_login" {
  description = "Azure AD admin login name"
  type        = string
  default     = null
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = null
}

variable "databases" {
  description = "Map of database configurations"
  type        = map(any)
  default     = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules (start_ip, end_ip)"
  type        = map(any)
  default     = {}
}

variable "vnet_rules" {
  description = "Map of VNet rule name to subnet ID"
  type        = map(string)
  default     = {}
}

variable "tde_key_vault_key_id" {
  description = "Key Vault key ID for TDE (null for service-managed)"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
