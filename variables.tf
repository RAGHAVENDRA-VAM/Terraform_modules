variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# ─── Deployment Toggles ─────────────────────────────────────────────────────

variable "deploy_aws" {
  description = "Deploy AWS resources"
  type        = bool
  default     = true
}

variable "deploy_azure" {
  description = "Deploy Azure resources"
  type        = bool
  default     = false
}

variable "deploy_gcp" {
  description = "Deploy GCP resources"
  type        = bool
  default     = false
}

variable "deploy_eks" {
  description = "Deploy AWS EKS cluster"
  type        = bool
  default     = false
}

variable "deploy_aks" {
  description = "Deploy Azure AKS cluster"
  type        = bool
  default     = false
}

variable "deploy_gke" {
  description = "Deploy GCP GKE cluster"
  type        = bool
  default     = false
}

# ─── AWS Variables ───────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID (used for unique resource names)"
  type        = string
  default     = "123456789012"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_azs" {
  description = "AWS availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_public_subnets" {
  description = "AWS public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "aws_private_subnets" {
  description = "AWS private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "aws_db_name" {
  description = "AWS RDS database name"
  type        = string
  default     = "appdb"
}

variable "aws_db_username" {
  description = "AWS RDS master username"
  type        = string
  default     = "dbadmin"
}

variable "aws_db_password" {
  description = "AWS RDS master password"
  type        = string
  sensitive   = true
}

# ─── Azure Variables ─────────────────────────────────────────────────────────

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "azure_resource_group" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-terraform-modules"
}

variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR"
  type        = string
  default     = "10.1.0.0/16"
}

variable "azure_public_subnet_cidr" {
  description = "Azure public subnet CIDR"
  type        = string
  default     = "10.1.1.0/24"
}

variable "azure_private_subnet_cidr" {
  description = "Azure private subnet CIDR"
  type        = string
  default     = "10.1.11.0/24"
}

# ─── GCP Variables ───────────────────────────────────────────────────────────

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = "my-gcp-project"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_subnet_cidr" {
  description = "GCP subnet CIDR"
  type        = string
  default     = "10.2.0.0/24"
}
