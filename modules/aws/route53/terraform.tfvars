# =============================================================================
# terraform.tfvars — AWS Route53 Module
# =============================================================================

create_zone   = true
zone_name     = "dev.example.com"
zone_comment  = "Dev environment hosted zone"
private_zone  = false

records = {
  www = {
    name    = "www"
    type    = "A"
    ttl     = 300
    records = ["1.2.3.4"]
  }
  api = {
    name    = "api"
    type    = "CNAME"
    ttl     = 300
    records = ["dev-alb-123.us-east-1.elb.amazonaws.com"]
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
