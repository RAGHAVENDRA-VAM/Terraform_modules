variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "database_version" {
  description = "Database version (e.g., POSTGRES_15, MYSQL_8_0)"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine tier (e.g., db-custom-2-7680)"
  type        = string
  default     = "db-custom-2-7680"
}

variable "availability_type" {
  description = "ZONAL or REGIONAL (HA)"
  type        = string
  default     = "ZONAL"
}

variable "disk_type" {
  description = "Disk type: PD_SSD or PD_HDD"
  type        = string
  default     = "PD_SSD"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "disk_autoresize" {
  description = "Enable disk auto-resize"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "backup_enabled" {
  type    = bool
  default = true
}

variable "backup_start_time" {
  type    = string
  default = "03:00"
}

variable "point_in_time_recovery_enabled" {
  type    = bool
  default = true
}

variable "transaction_log_retention_days" {
  type    = number
  default = 7
}

variable "retained_backups" {
  type    = number
  default = 7
}

variable "ipv4_enabled" {
  description = "Enable public IPv4"
  type        = bool
  default     = false
}

variable "private_network" {
  description = "VPC network self link for private IP"
  type        = string
  default     = null
}

variable "require_ssl" {
  description = "Require SSL connections"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "List of authorized networks (name, cidr)"
  type        = list(map(string))
  default     = []
}

variable "maintenance_window_day" {
  description = "Day of week for maintenance (1=Monday)"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour for maintenance (UTC)"
  type        = number
  default     = 3
}

variable "query_insights_enabled" {
  type    = bool
  default = true
}

variable "database_flags" {
  description = "List of database flags"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "databases" {
  description = "Map of databases to create"
  type        = map(any)
  default     = {}
}

variable "users" {
  description = "Map of users to create"
  type        = map(any)
  default     = {}
  sensitive   = true
}

variable "read_replicas" {
  description = "Map of read replica configurations"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}
