# =============================================================================
# terraform.tfvars — AWS Security Group Module
# =============================================================================

name        = "dev-web-sg"
description = "Web tier security group"
vpc_id      = "vpc-0abc123def456"

ingress_rules = [
  {
    ip_protocol = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_ipv4   = "0.0.0.0/0"
    description = "HTTP"
  },
  {
    ip_protocol = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_ipv4   = "0.0.0.0/0"
    description = "HTTPS"
  }
]

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
