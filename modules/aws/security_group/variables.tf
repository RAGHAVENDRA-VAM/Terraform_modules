variable "name" {
  description = "Security group name"
  type        = string
}

variable "description" {
  description = "Security group description"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type        = list(map(string))
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(map(string))
  default = [
    {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound"
    }
  ]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
