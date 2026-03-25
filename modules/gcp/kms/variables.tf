variable "key_ring_name" {
  description = "KMS key ring name"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Key ring location"
  type        = string
}

variable "crypto_keys" {
  description = "Map of crypto key configurations"
  type        = map(any)
  default     = {}
}
