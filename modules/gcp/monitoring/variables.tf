variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "notification_channels" {
  description = "Map of notification channels"
  type        = map(any)
  default     = {}
}

variable "alert_policies" {
  description = "Map of alert policies"
  type        = map(any)
  default     = {}
}

variable "uptime_checks" {
  description = "Map of uptime check configurations"
  type        = map(any)
  default     = {}
}

variable "log_metrics" {
  description = "Map of log-based metrics"
  type        = map(any)
  default     = {}
}
