variable "create_zone" {
  description = "Create a new hosted zone"
  type        = bool
  default     = true
}

variable "zone_name" {
  description = "Hosted zone domain name"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "Existing zone ID (when create_zone = false)"
  type        = string
  default     = ""
}

variable "zone_comment" {
  description = "Hosted zone comment"
  type        = string
  default     = "Managed by Terraform"
}

variable "private_zone" {
  description = "Create a private hosted zone"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
  default     = null
}

variable "records" {
  description = "Map of DNS records to create"
  type        = map(any)
  default     = {}
}

variable "health_checks" {
  description = "Map of Route53 health checks"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
