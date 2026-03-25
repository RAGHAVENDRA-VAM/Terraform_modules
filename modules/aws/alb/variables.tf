variable "name" {
  description = "ALB name"
  type        = string
}

variable "internal" {
  description = "Create an internal load balancer"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Load balancer type (application or network)"
  type        = string
  default     = "application"
}

variable "security_group_ids" {
  description = "Security group IDs (ALB only)"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target groups"
  type        = string
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = true
}

variable "idle_timeout" {
  type    = number
  default = 60
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  type    = string
  default = "alb-logs"
}

variable "target_groups" {
  description = "Map of target group configurations"
  type        = map(any)
  default     = {}
}

variable "create_http_listener" {
  type    = bool
  default = true
}

variable "http_redirect_to_https" {
  type    = bool
  default = false
}

variable "create_https_listener" {
  type    = bool
  default = false
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}

variable "default_target_group" {
  description = "Key of the default target group for HTTPS listener"
  type        = string
  default     = ""
}

variable "listener_rules" {
  description = "Map of listener rules"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
