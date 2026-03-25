variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Additional security group IDs"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to access the public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "kms_key_arn" {
  description = "KMS key ARN for secrets encryption"
  type        = string
  default     = null
}

variable "node_groups" {
  description = "Map of node group configurations"
  type        = map(any)
  default = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 4
    }
  }
}

variable "cluster_addons" {
  description = "Map of EKS addons to install"
  type        = map(any)
  default = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
