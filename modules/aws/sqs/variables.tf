variable "name" {
  description = "SQS queue name"
  type        = string
}

variable "fifo_queue" {
  description = "Create a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Delivery delay in seconds"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time in seconds"
  type        = number
  default     = 0
}

variable "kms_master_key_id" {
  description = "KMS key ID for SSE"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  type    = number
  default = 300
}

variable "dead_letter_queue_arn" {
  description = "ARN of an existing DLQ"
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Max receive count before sending to DLQ"
  type        = number
  default     = 5
}

variable "create_dlq" {
  description = "Create a dead-letter queue"
  type        = bool
  default     = false
}

variable "dlq_message_retention_seconds" {
  type    = number
  default = 1209600
}

variable "queue_policy" {
  description = "JSON queue policy document"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
