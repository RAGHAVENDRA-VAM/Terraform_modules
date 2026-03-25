terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws     = { source = "hashicorp/aws",     version = ">= 5.0" }
    azurerm = { source = "hashicorp/azurerm", version = ">= 3.0" }
    google  = { source = "hashicorp/google",  version = ">= 5.0" }
  }
}

provider "aws"     { region = "us-east-1" }
provider "azurerm" { features {} }
provider "google"  { project = var.gcp_project_id; region = "us-central1" }

# ─────────────────────────────────────────────────────────────────────────────
# AZURE — App Service (Web App)
# ─────────────────────────────────────────────────────────────────────────────
module "azure_webapp" {
  source = "../../modules/azure/webapp"

  app_name            = "myapp-prod"
  location            = "East US"
  resource_group_name = var.azure_resource_group
  sku_name            = "P1v3"
  os_type             = "Linux"

  # Node.js 20 runtime
  application_stack = {
    node_version = "20-lts"
  }

  health_check_path = "/health"
  always_on         = true

  app_settings = {
    NODE_ENV     = "production"
    DATABASE_URL = var.database_url
    REDIS_URL    = var.redis_url
  }

  # Staging slot for blue/green deployments
  deployment_slots = {
    staging = {
      always_on   = true
      app_settings = {
        NODE_ENV = "staging"
      }
    }
  }

  # Autoscale: 1–5 instances based on CPU
  autoscale = {
    min_count     = 1
    max_count     = 5
    default_count = 2
  }

  # VNet integration for private DB access
  vnet_integration_subnet_id = var.azure_app_subnet_id

  # Custom domain
  custom_hostnames = ["app.example.com"]

  # Diagnostics
  log_analytics_workspace_id = var.azure_log_analytics_id

  tags = { Environment = "production", App = "myapp" }
}

# ─────────────────────────────────────────────────────────────────────────────
# AWS — Elastic Beanstalk (equivalent to Azure App Service)
# ─────────────────────────────────────────────────────────────────────────────
module "aws_webapp" {
  source = "../../modules/aws/elastic_beanstalk"

  app_name         = "myapp"
  environment_name = "prod"

  # Node.js 20 on Amazon Linux 2023
  solution_stack_name = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"

  # VPC placement
  vpc_id              = var.aws_vpc_id
  instance_subnet_ids = var.aws_private_subnet_ids
  elb_subnet_ids      = var.aws_public_subnet_ids
  security_group_ids  = [var.aws_app_sg_id]

  # Instance sizing
  instance_type = "t3.small"
  min_instances = 2
  max_instances = 6

  # Rolling deployment (30% at a time)
  deployment_policy = "Rolling"
  batch_size_type   = "Percentage"
  batch_size        = 30

  # Health check
  health_check_path       = "/health"
  health_reporting_system = "enhanced"

  # HTTPS
  ssl_certificate_arn = var.aws_acm_cert_arn

  # Environment variables
  env_vars = {
    NODE_ENV     = "production"
    DATABASE_URL = var.database_url
    REDIS_URL    = var.redis_url
  }

  # CloudWatch log streaming
  stream_logs        = true
  log_retention_days = 14

  tags = { Environment = "production", App = "myapp" }
}

# ─────────────────────────────────────────────────────────────────────────────
# GCP — App Engine (equivalent to Azure App Service)
# ─────────────────────────────────────────────────────────────────────────────
module "gcp_webapp" {
  source = "../../modules/gcp/appengine"

  project_id   = var.gcp_project_id
  create_app   = true
  location_id  = "us-central"
  service_name = "default"
  version_id   = "v1"
  runtime_type = "standard"
  runtime      = "nodejs20"
  instance_class = "F2"

  entrypoint = "node server.js"

  deployment_zip = {
    source_url = "https://storage.googleapis.com/${var.gcp_bucket}/app.zip"
  }

  env_variables = {
    NODE_ENV     = "production"
    DATABASE_URL = var.database_url
    REDIS_URL    = var.redis_url
  }

  # Autoscale: 1–10 instances
  scaling_type = "automatic"
  automatic_scaling = {
    min_instances          = 1
    max_instances          = 10
    target_cpu_utilization = 0.6
  }

  # VPC connector for private Cloud SQL access
  create_vpc_connector = true
  vpc_connector_cidr   = "10.8.0.0/28"
  network_name         = var.gcp_network_name

  # Custom domain
  custom_domains = ["app.example.com"]

  # Firewall: allow only HTTPS
  firewall_rules = {
    allow-all = {
      priority     = 1000
      action       = "ALLOW"
      source_range = "*"
      description  = "Allow all traffic"
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Variables
# ─────────────────────────────────────────────────────────────────────────────
variable "gcp_project_id"        { type = string }
variable "gcp_bucket"            { type = string }
variable "gcp_network_name"      { type = string }
variable "azure_resource_group"  { type = string }
variable "azure_app_subnet_id"   { type = string }
variable "azure_log_analytics_id"{ type = string }
variable "aws_vpc_id"            { type = string }
variable "aws_private_subnet_ids"{ type = list(string) }
variable "aws_public_subnet_ids" { type = list(string) }
variable "aws_app_sg_id"         { type = string }
variable "aws_acm_cert_arn"      { type = string }
variable "database_url"          { type = string; sensitive = true }
variable "redis_url"             { type = string; sensitive = true }

# ─────────────────────────────────────────────────────────────────────────────
# Outputs — all three web app endpoints
# ─────────────────────────────────────────────────────────────────────────────
output "azure_webapp_url" {
  description = "Azure Web App URL"
  value       = module.azure_webapp.default_site_url
}

output "azure_webapp_staging_url" {
  description = "Azure staging slot URL"
  value       = "https://${module.azure_webapp.linux_slot_hostnames["staging"]}"
}

output "azure_webapp_identity" {
  description = "Azure Web App managed identity"
  value       = module.azure_webapp.identity_principal_id
}

output "aws_webapp_endpoint" {
  description = "AWS Elastic Beanstalk endpoint"
  value       = "https://${module.aws_webapp.cname}"
}

output "aws_webapp_load_balancers" {
  description = "AWS load balancer ARNs"
  value       = module.aws_webapp.load_balancers
}

output "gcp_webapp_url" {
  description = "GCP App Engine URL"
  value       = module.gcp_webapp.app_url
}

output "gcp_webapp_service_url" {
  description = "GCP App Engine service URL"
  value       = module.gcp_webapp.service_url
}
