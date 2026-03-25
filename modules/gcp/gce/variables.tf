variable "name" {
  description = "Instance name"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-medium"
}

variable "description" {
  description = "Instance description"
  type        = string
  default     = ""
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "network_tags" {
  description = "Network tags for firewall rules"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-ssd"
}

variable "boot_disk_auto_delete" {
  description = "Auto-delete boot disk on instance deletion"
  type        = bool
  default     = true
}

variable "additional_disks" {
  description = "Map of additional disk configurations"
  type        = map(any)
  default     = {}
}

variable "network" {
  description = "VPC network self link or name"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self link or name"
  type        = string
}

variable "create_public_ip" {
  description = "Create a public IP (ephemeral)"
  type        = bool
  default     = false
}

variable "static_ip" {
  description = "Static external IP address"
  type        = string
  default     = null
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Service account scopes"
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "metadata" {
  description = "Instance metadata"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Startup script"
  type        = string
  default     = null
}

variable "enable_secure_boot" {
  description = "Enable Shielded VM secure boot"
  type        = bool
  default     = true
}

variable "preemptible" {
  description = "Create a preemptible instance"
  type        = bool
  default     = false
}
