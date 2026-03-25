variable "bucket_name" {
  description = "GCS bucket name (globally unique)"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Bucket location (region, dual-region, or multi-region)"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class: STANDARD, NEARLINE, COLDLINE, ARCHIVE"
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty"
  type        = bool
  default     = false
}

variable "public_access_prevention" {
  description = "Public access prevention: enforced or inherited"
  type        = string
  default     = "enforced"
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type        = list(any)
  default     = []
}

variable "cors_rules" {
  description = "List of CORS rules"
  type        = list(any)
  default     = []
}

variable "log_bucket" {
  description = "Bucket for access logs"
  type        = string
  default     = null
}

variable "log_object_prefix" {
  description = "Prefix for log objects"
  type        = string
  default     = "logs/"
}

variable "kms_key_name" {
  description = "KMS key name for CMEK encryption"
  type        = string
  default     = null
}

variable "iam_bindings" {
  description = "Map of role to list of members"
  type        = map(list(string))
  default     = {}
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}
