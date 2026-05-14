# =============================================================================
# terraform.tfvars
# Webapp Example — Azure App Service + AWS Elastic Beanstalk + GCP App Engine
# =============================================================================

# GCP
gcp_project_id   = "my-gcp-project-id"
gcp_bucket       = "my-gcp-app-bucket"
gcp_network_name = "dev-vpc"

# Azure
azure_resource_group   = "rg-dev-webapp"
azure_app_subnet_id    = "/subscriptions/<sub-id>/resourceGroups/rg-dev-webapp/providers/Microsoft.Network/virtualNetworks/dev-vnet/subnets/private"
azure_log_analytics_id = "/subscriptions/<sub-id>/resourceGroups/rg-dev-webapp/providers/Microsoft.OperationalInsights/workspaces/dev-law"

# AWS
aws_vpc_id             = "vpc-0abc123def456"
aws_private_subnet_ids = ["subnet-0abc111", "subnet-0abc222"]
aws_public_subnet_ids  = ["subnet-0abc333", "subnet-0abc444"]
aws_app_sg_id          = "sg-0abc123def456"
aws_acm_cert_arn       = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"

# Shared app config
database_url = "postgresql://dbadmin:Change_Me@db-host:5432/appdb"
redis_url    = "redis://redis-host:6379"
