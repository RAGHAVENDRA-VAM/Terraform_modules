variable "vm_name" {
  description = "Virtual machine name"
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

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "os_type" {
  description = "OS type: linux or windows"
  type        = string
  default     = "linux"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for Linux VMs"
  type        = string
  default     = null
}

variable "admin_password" {
  description = "Admin password for Windows VMs"
  type        = string
  default     = null
  sensitive   = true
}

variable "subnet_id" {
  description = "Subnet ID for the NIC"
  type        = string
}

variable "private_ip_address" {
  description = "Static private IP (null for dynamic)"
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Create and attach a public IP"
  type        = bool
  default     = false
}

variable "os_disk_type" {
  description = "OS disk storage type"
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "image_publisher" {
  description = "Image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "Image version"
  type        = string
  default     = "latest"
}

variable "identity_type" {
  description = "Managed identity type"
  type        = string
  default     = "SystemAssigned"
}

variable "custom_data" {
  description = "Cloud-init custom data script"
  type        = string
  default     = null
}

variable "boot_diagnostics_storage_uri" {
  description = "Storage account URI for boot diagnostics"
  type        = string
  default     = null
}

variable "data_disks" {
  description = "Map of data disk configurations"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
