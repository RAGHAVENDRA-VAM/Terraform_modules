variable "storage_account_name" {
  description = "Storage account name (3-24 chars, lowercase alphanumeric)"
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

variable "account_tier" {
  description = "Storage account tier: Standard or Premium"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS"
  type        = string
  default     = "GRS"
}

variable "account_kind" {
  description = "Account kind: StorageV2, BlobStorage, etc."
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Access tier: Hot or Cool"
  type        = string
  default     = "Hot"
}

variable "shared_access_key_enabled" {
  description = "Enable shared access key authentication"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

variable "enable_soft_delete" {
  description = "Enable soft delete for blobs and containers"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days"
  type        = number
  default     = 7
}

variable "network_rules" {
  description = "Network rules configuration"
  type        = map(any)
  default     = null
}

variable "containers" {
  description = "Map of blob containers to create"
  type        = map(any)
  default     = {}
}

variable "queues" {
  description = "Map of storage queues to create"
  type        = map(any)
  default     = {}
}

variable "tables" {
  description = "Map of storage tables to create"
  type        = map(any)
  default     = {}
}

variable "file_shares" {
  description = "Map of file shares to create"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
