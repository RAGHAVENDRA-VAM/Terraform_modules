variable "name" {
  description = "Load balancer name prefix"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for regional LB"
  type        = string
  default     = null
}

variable "lb_type" {
  description = "Load balancer type: global or regional"
  type        = string
  default     = "global"
}

variable "health_checks" {
  description = "Map of health check configurations"
  type        = map(any)
  default     = {}
}

variable "backend_services" {
  description = "Map of backend service configurations"
  type        = map(any)
  default     = {}
}

variable "default_backend_service" {
  description = "Key of the default backend service"
  type        = string
}

variable "url_map_rules" {
  description = "Map of URL map host rules and path matchers"
  type        = map(any)
  default     = {}
}

variable "create_https_proxy" {
  description = "Create an HTTPS target proxy"
  type        = bool
  default     = true
}

variable "create_http_proxy" {
  description = "Create an HTTP target proxy"
  type        = bool
  default     = false
}

variable "ssl_certificate_ids" {
  description = "List of SSL certificate IDs"
  type        = list(string)
  default     = []
}
