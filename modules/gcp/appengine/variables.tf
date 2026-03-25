variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (for VPC connector)"
  type        = string
  default     = "us-central1"
}

# ─── App Engine Application ──────────────────────────────────────────────────

variable "create_app" {
  description = "Create the App Engine application (only once per project)"
  type        = bool
  default     = true
}

variable "location_id" {
  description = "App Engine location (e.g., us-central, us-east1)"
  type        = string
  default     = "us-central"
}

variable "database_type" {
  description = "Database type: CLOUD_DATASTORE_COMPATIBILITY or CLOUD_FIRESTORE"
  type        = string
  default     = "CLOUD_FIRESTORE"
}

variable "split_health_checks" {
  description = "Enable split health checks"
  type        = bool
  default     = true
}

variable "iap" {
  description = "Identity-Aware Proxy configuration"
  type        = map(string)
  default     = null
}

# ─── Service / Version ───────────────────────────────────────────────────────

variable "service_name" {
  description = "App Engine service name"
  type        = string
  default     = "default"
}

variable "version_id" {
  description = "Version ID"
  type        = string
  default     = "v1"
}

variable "runtime_type" {
  description = "Runtime environment: standard or flexible"
  type        = string
  default     = "standard"
}

variable "runtime" {
  description = "Runtime (e.g., nodejs20, python312, java21, go122, php82, ruby32)"
  type        = string
  default     = "nodejs20"
}

variable "instance_class" {
  description = "Instance class for standard environment (F1, F2, F4, F4_1G, B1, B2, B4, B8)"
  type        = string
  default     = "F2"
}

variable "entrypoint" {
  description = "Entrypoint command"
  type        = string
  default     = null
}

variable "container_image" {
  description = "Docker container image (flexible environment)"
  type        = string
  default     = null
}

# ─── Deployment ──────────────────────────────────────────────────────────────

variable "deployment_zip" {
  description = "Zip deployment configuration (source_url, files_count)"
  type        = map(any)
  default     = null
}

variable "deployment_files" {
  description = "Map of individual deployment files"
  type        = map(any)
  default     = {}
}

# ─── Environment Variables ───────────────────────────────────────────────────

variable "env_variables" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

# ─── Scaling ─────────────────────────────────────────────────────────────────

variable "scaling_type" {
  description = "Scaling type: automatic, basic, or manual"
  type        = string
  default     = "automatic"
}

variable "automatic_scaling" {
  description = "Automatic scaling configuration"
  type        = map(any)
  default = {
    max_concurrent_requests = 10
    min_instances           = 0
    max_instances           = 10
    target_cpu_utilization  = 0.6
  }
}

variable "basic_scaling" {
  description = "Basic scaling configuration"
  type        = map(any)
  default = {
    max_instances = 5
    idle_timeout  = "5m"
  }
}

variable "manual_scaling" {
  description = "Manual scaling configuration"
  type        = map(any)
  default = {
    instances = 1
  }
}

# ─── Resources (Flexible only) ───────────────────────────────────────────────

variable "resources" {
  description = "Resource configuration for flexible environment (cpu, memory_gb, disk_gb)"
  type        = map(any)
  default = {
    cpu       = 1
    memory_gb = 0.6
    disk_gb   = 10
  }
}

# ─── Health Checks (Flexible only) ───────────────────────────────────────────

variable "liveness_check" {
  description = "Liveness check configuration"
  type        = map(any)
  default     = null
}

variable "readiness_check" {
  description = "Readiness check configuration"
  type        = map(any)
  default     = null
}

# ─── Handlers (Standard only) ────────────────────────────────────────────────

variable "handlers" {
  description = "List of URL handler configurations"
  type        = list(any)
  default     = []
}

# ─── Network ─────────────────────────────────────────────────────────────────

variable "network_name" {
  description = "VPC network name for flexible environment"
  type        = string
  default     = null
}

variable "subnetwork_name" {
  description = "Subnetwork name for flexible environment"
  type        = string
  default     = null
}

variable "forwarded_ports" {
  description = "Forwarded ports for flexible environment"
  type        = list(string)
  default     = []
}

variable "service_account_email" {
  description = "Service account email for flexible environment"
  type        = string
  default     = null
}

# ─── VPC Connector ───────────────────────────────────────────────────────────

variable "create_vpc_connector" {
  description = "Create a Serverless VPC Access connector"
  type        = bool
  default     = false
}

variable "vpc_connector_name" {
  description = "Existing VPC connector name (or created one)"
  type        = string
  default     = null
}

variable "vpc_connector_cidr" {
  description = "CIDR range for the VPC connector (/28)"
  type        = string
  default     = "10.8.0.0/28"
}

variable "vpc_connector_config" {
  description = "VPC connector configuration (min_instances, max_instances, machine_type)"
  type        = map(any)
  default     = {}
}

# ─── Traffic Splitting ───────────────────────────────────────────────────────

variable "traffic_split" {
  description = "Map of version_id to traffic allocation (must sum to 1)"
  type        = map(number)
  default     = {}
}

variable "migrate_traffic" {
  description = "Gradually migrate traffic to new version"
  type        = bool
  default     = false
}

variable "shard_by" {
  description = "Traffic sharding method: COOKIE, IP, or RANDOM"
  type        = string
  default     = "IP"
}

# ─── Custom Domains ──────────────────────────────────────────────────────────

variable "custom_domains" {
  description = "List of custom domains to map"
  type        = list(string)
  default     = []
}

# ─── Firewall ────────────────────────────────────────────────────────────────

variable "firewall_rules" {
  description = "Map of App Engine firewall rules"
  type        = map(any)
  default     = {}
}

# ─── Lifecycle ───────────────────────────────────────────────────────────────

variable "delete_service_on_destroy" {
  description = "Delete the service when the version is destroyed"
  type        = bool
  default     = false
}

variable "noop_on_destroy" {
  description = "Do nothing on destroy (keep the version running)"
  type        = bool
  default     = true
}
