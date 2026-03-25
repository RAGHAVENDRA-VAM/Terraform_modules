variable "alias" {
  description = "KMS key alias (without alias/ prefix)"
  type        = string
}

variable "description" {
  description = "KMS key description"
  type        = string
  default     = "Managed by Terraform"
}

variable "key_usage" {
  description = "Key usage: ENCRYPT_DECRYPT or SIGN_VERIFY"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "Key spec"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "key_policy" {
  description = "JSON key policy"
  type        = string
  default     = null
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "rotation_period_in_days" {
  description = "Key rotation period in days (90-2560)"
  type        = number
  default     = 365
}

variable "deletion_window_in_days" {
  description = "Waiting period before key deletion (7-30)"
  type        = number
  default     = 30
}

variable "is_enabled" {
  description = "Enable the key"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Create a multi-region key"
  type        = bool
  default     = false
}

variable "grants" {
  description = "Map of KMS grants"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
