variable "log_groups" {
  description = "Map of CloudWatch log groups to create"
  type        = map(any)
  default     = {}
}

variable "metric_alarms" {
  description = "Map of CloudWatch metric alarms"
  type        = map(any)
  default     = {}
}

variable "dashboards" {
  description = "Map of dashboard name to JSON body"
  type        = map(string)
  default     = {}
}

variable "event_rules" {
  description = "Map of EventBridge rules"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
