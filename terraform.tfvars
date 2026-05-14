# =============================================================================
# terraform.tfvars
# Root Module — Actual environment values for AWS, Azure, and GCP
# =============================================================================

# -----------------------------------------------------------------------------
# Global
# -----------------------------------------------------------------------------
environment = "dev"

common_tags = {
  Project     = "multi-cloud-infra"
  Owner       = "raghava"
  ManagedBy   = "Terraform"
  Environment = "dev"
}

# -----------------------------------------------------------------------------
# Deployment Toggles
# -----------------------------------------------------------------------------
deploy_aws   = true
deploy_azure = false
deploy_gcp   = false
deploy_eks   = false
deploy_aks   = false
deploy_gke   = false

# -----------------------------------------------------------------------------
# AWS
# -----------------------------------------------------------------------------
aws_region     = "us-east-1"
aws_account_id = "123456789012"

aws_vpc_cidr        = "10.0.0.0/16"
aws_azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
aws_public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
aws_private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

aws_db_name     = "appdb"
aws_db_username = "dbadmin"
aws_db_password = "Change_Me_Before_Apply_123!"   # override via env: TF_VAR_aws_db_password

# -----------------------------------------------------------------------------
# Azure
# -----------------------------------------------------------------------------
azure_location       = "East US"
azure_resource_group = "rg-dev-multi-cloud"

azure_vnet_cidr           = "10.1.0.0/16"
azure_public_subnet_cidr  = "10.1.1.0/24"
azure_private_subnet_cidr = "10.1.11.0/24"

# -----------------------------------------------------------------------------
# GCP
# -----------------------------------------------------------------------------
gcp_project_id  = "my-gcp-project-id"
gcp_region      = "us-central1"
gcp_subnet_cidr = "10.2.0.0/24"
