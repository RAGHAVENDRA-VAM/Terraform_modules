variable "cluster_id" {
  description = "ElastiCache cluster/replication group ID"
  type        = string
}

variable "description" {
  description = "Description for the replication group"
  type        = string
  default     = "Managed by Terraform"
}

variable "engine" {
  description = "Cache engine: redis or memcached"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "Cache engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "port" {
  description = "Cache port"
  type        = number
  default     = 6379
}

variable "subnet_ids" {
  description = "Subnet IDs for the cache subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "parameter_group_name" {
  type    = string
  default = null
}

variable "parameter_group_family" {
  type    = string
  default = "redis7"
}

variable "parameters" {
  type    = list(object({ name = string, value = string }))
  default = []
}

variable "at_rest_encryption_enabled" {
  type    = bool
  default = true
}

variable "transit_encryption_enabled" {
  type    = bool
  default = true
}

variable "auth_token" {
  description = "Auth token for Redis in-transit encryption"
  type        = string
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "multi_az_enabled" {
  type    = bool
  default = false
}

variable "maintenance_window" {
  type    = string
  default = "sun:05:00-sun:06:00"
}

variable "snapshot_retention_limit" {
  type    = number
  default = 1
}

variable "snapshot_window" {
  type    = string
  default = "03:00-04:00"
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
