variable "name" {
  description = "SNS topic name"
  type        = string
}

variable "fifo_topic" {
  description = "Create a FIFO topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  type    = bool
  default = false
}

variable "display_name" {
  description = "Display name for SMS subscriptions"
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "KMS key ID for SSE"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "JSON delivery policy"
  type        = string
  default     = null
}

variable "topic_policy" {
  description = "JSON topic policy"
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "Map of subscriptions (protocol, endpoint)"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
