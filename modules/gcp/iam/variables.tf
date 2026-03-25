variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_accounts" {
  description = "Map of service accounts to create with optional roles and workload identity"
  type        = map(any)
  default     = {}
}

variable "project_iam_bindings" {
  description = "Map of member to list of roles for project-level IAM"
  type        = map(list(string))
  default     = {}
}

variable "custom_roles" {
  description = "Map of custom IAM roles"
  type        = map(any)
  default     = {}
}
