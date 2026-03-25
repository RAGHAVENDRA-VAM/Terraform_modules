variable "app_name" {
  description = "Web app name (must be globally unique)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

# ─── App Service Plan ────────────────────────────────────────────────────────

variable "sku_name" {
  description = "App Service Plan SKU (e.g., B1, B2, S1, P1v3, P2v3)"
  type        = string
  default     = "P1v3"
}

variable "os_type" {
  description = "OS type: Linux or Windows"
  type        = string
  default     = "Linux"
}

variable "worker_count" {
  description = "Number of workers in the App Service Plan"
  type        = number
  default     = 1
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing (requires Premium SKU)"
  type        = bool
  default     = false
}

# ─── Web App ─────────────────────────────────────────────────────────────────

variable "always_on" {
  description = "Keep the app always loaded"
  type        = bool
  default     = true
}

variable "client_affinity_enabled" {
  description = "Enable client affinity (sticky sessions)"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = null
}

variable "site_worker_count" {
  description = "Number of workers for the web app"
  type        = number
  default     = 1
}

variable "application_stack" {
  description = "Application stack configuration (runtime settings)"
  type        = map(string)
  default     = null
}

variable "app_settings" {
  description = "Application settings (environment variables)"
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "Map of connection strings (type: SQLAzure, SQLServer, Custom, etc.)"
  type = map(object({
    type  = string
    value = string
  }))
  default   = {}
  sensitive = true
}

variable "sticky_app_settings" {
  description = "App setting names that are sticky to a slot"
  type        = list(string)
  default     = []
}

variable "sticky_connection_string_names" {
  description = "Connection string names that are sticky to a slot"
  type        = list(string)
  default     = []
}

variable "ip_restrictions" {
  description = "List of IP restriction rules"
  type        = list(any)
  default     = []
}

variable "cors" {
  description = "CORS configuration (allowed_origins, support_credentials)"
  type        = map(any)
  default     = null
}

variable "identity_ids" {
  description = "List of user-assigned managed identity IDs"
  type        = list(string)
  default     = null
}

variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

# ─── Logging ─────────────────────────────────────────────────────────────────

variable "enable_logging" {
  description = "Enable HTTP and failed request logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "HTTP log retention in days"
  type        = number
  default     = 7
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

# ─── Backup ──────────────────────────────────────────────────────────────────

variable "backup_storage_url" {
  description = "SAS URL of the storage container for backups"
  type        = string
  default     = null
  sensitive   = true
}

variable "backup_frequency_interval" {
  description = "Backup frequency interval"
  type        = number
  default     = 1
}

variable "backup_frequency_unit" {
  description = "Backup frequency unit: Hour or Day"
  type        = string
  default     = "Day"
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 30
}

# ─── Auth ────────────────────────────────────────────────────────────────────

variable "auth_settings" {
  description = "Authentication settings (Easy Auth v2)"
  type        = map(any)
  default     = null
}

# ─── Deployment Slots ────────────────────────────────────────────────────────

variable "deployment_slots" {
  description = "Map of deployment slot configurations"
  type        = map(any)
  default     = {}
}

# ─── Custom Domains ──────────────────────────────────────────────────────────

variable "custom_hostnames" {
  description = "List of custom hostnames to bind (DNS must be pre-configured)"
  type        = list(string)
  default     = []
}

# ─── Autoscale ───────────────────────────────────────────────────────────────

variable "autoscale" {
  description = "Autoscale configuration (min_count, max_count, default_count, scale_out_rules, scale_in_rules)"
  type        = map(any)
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
