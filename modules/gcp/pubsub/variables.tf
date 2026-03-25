variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "topics" {
  description = "Map of topics with optional subscriptions and IAM bindings"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}
