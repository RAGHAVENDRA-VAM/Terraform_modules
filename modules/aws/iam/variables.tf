variable "create_role" {
  description = "Create an IAM role"
  type        = bool
  default     = false
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = ""
}

variable "role_description" {
  description = "IAM role description"
  type        = string
  default     = ""
}

variable "assume_role_policy" {
  description = "JSON assume role policy document"
  type        = string
  default     = ""
}

variable "role_path" {
  description = "IAM role path"
  type        = string
  default     = "/"
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy name to JSON policy document"
  type        = map(string)
  default     = {}
}

variable "create_instance_profile" {
  description = "Create an EC2 instance profile"
  type        = bool
  default     = false
}

variable "create_policy" {
  description = "Create a standalone IAM policy"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "IAM policy name"
  type        = string
  default     = ""
}

variable "policy_description" {
  description = "IAM policy description"
  type        = string
  default     = ""
}

variable "policy_document" {
  description = "JSON policy document"
  type        = string
  default     = ""
}

variable "policy_path" {
  description = "IAM policy path"
  type        = string
  default     = "/"
}

variable "users" {
  description = "Map of IAM users to create with optional policy_arns"
  type        = map(any)
  default     = {}
}

variable "groups" {
  description = "Map of IAM groups to create with optional policy_arns"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
