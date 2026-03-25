variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption"
  type        = string
  default     = null
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type        = list(any)
  default     = []
}

variable "bucket_policy" {
  description = "JSON bucket policy document"
  type        = string
  default     = null
}

variable "cors_rules" {
  description = "List of CORS rules"
  type        = list(any)
  default     = []
}

variable "logging_target_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "logs/"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
