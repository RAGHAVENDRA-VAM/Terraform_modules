# =============================================================================
# terraform.tfvars — AWS ALB Module
# =============================================================================

name               = "dev-alb"
internal           = false
load_balancer_type = "application"
vpc_id             = "vpc-0abc123def456"
subnet_ids         = ["subnet-0abc333", "subnet-0abc444"]
security_group_ids = ["sg-0abc123def456"]

enable_deletion_protection = false

target_groups = {
  web = {
    port              = 80
    protocol          = "HTTP"
    target_type       = "instance"
    health_check_path = "/health"
  }
}

create_http_listener   = true
http_redirect_to_https = false
default_target_group   = "web"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
