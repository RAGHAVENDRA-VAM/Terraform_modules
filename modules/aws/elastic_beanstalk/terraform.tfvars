# =============================================================================
# terraform.tfvars — AWS Elastic Beanstalk Module
# =============================================================================

app_name         = "dev-webapp"
environment_name = "dev"
description      = "Dev web application"

solution_stack_name = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
tier                = "WebServer"

vpc_id              = "vpc-0abc123def456"
instance_subnet_ids = ["subnet-0abc111", "subnet-0abc222"]
elb_subnet_ids      = ["subnet-0abc333", "subnet-0abc444"]
security_group_ids  = ["sg-0abc123def456"]

instance_type = "t3.small"
min_instances = 1
max_instances = 3

environment_type   = "LoadBalanced"
load_balancer_type = "application"
health_check_path  = "/health"

deployment_policy = "Rolling"
batch_size_type   = "Percentage"
batch_size        = 30

stream_logs        = true
log_retention_days = 14

env_vars = {
  NODE_ENV  = "development"
  LOG_LEVEL = "debug"
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
