terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ─── AWS ────────────────────────────────────────────────────────────────────

module "aws_kms" {
  source = "./modules/aws/kms"
  count  = var.deploy_aws ? 1 : 0

  alias       = "${var.environment}-main"
  description = "Main KMS key for ${var.environment}"
  tags        = local.aws_tags
}

module "aws_vpc" {
  source = "./modules/aws/vpc"
  count  = var.deploy_aws ? 1 : 0

  name            = "${var.environment}-vpc"
  cidr_block      = var.aws_vpc_cidr
  azs             = var.aws_azs
  public_subnets  = var.aws_public_subnets
  private_subnets = var.aws_private_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.environment != "production"

  tags = local.aws_tags
}

module "aws_sg_web" {
  source = "./modules/aws/security_group"
  count  = var.deploy_aws ? 1 : 0

  name   = "${var.environment}-web-sg"
  vpc_id = module.aws_vpc[0].vpc_id

  ingress_rules = [
    { ip_protocol = "tcp", from_port = "80",  to_port = "80",  cidr_ipv4 = "0.0.0.0/0", description = "HTTP" },
    { ip_protocol = "tcp", from_port = "443", to_port = "443", cidr_ipv4 = "0.0.0.0/0", description = "HTTPS" }
  ]

  tags = local.aws_tags
}

module "aws_s3_app" {
  source = "./modules/aws/s3"
  count  = var.deploy_aws ? 1 : 0

  bucket_name        = "${var.environment}-app-${var.aws_account_id}"
  versioning_enabled = true
  kms_key_arn        = module.aws_kms[0].key_arn

  lifecycle_rules = [
    {
      id      = "transition-to-ia"
      transitions = [{ days = 30, storage_class = "STANDARD_IA" }]
      noncurrent_version_expiration_days = 90
    }
  ]

  tags = local.aws_tags
}

module "aws_rds" {
  source = "./modules/aws/rds"
  count  = var.deploy_aws ? 1 : 0

  identifier         = "${var.environment}-postgres"
  engine             = "postgres"
  engine_version     = "15.4"
  instance_class     = var.environment == "production" ? "db.r6g.large" : "db.t3.medium"
  db_name            = var.aws_db_name
  username           = var.aws_db_username
  password           = var.aws_db_password
  subnet_ids         = module.aws_vpc[0].private_subnet_ids
  security_group_ids = [module.aws_sg_web[0].sg_id]
  multi_az           = var.environment == "production"
  kms_key_id         = module.aws_kms[0].key_arn

  tags = local.aws_tags
}

module "aws_eks" {
  source = "./modules/aws/eks"
  count  = var.deploy_aws && var.deploy_eks ? 1 : 0

  cluster_name = "${var.environment}-eks"
  subnet_ids   = concat(module.aws_vpc[0].public_subnet_ids, module.aws_vpc[0].private_subnet_ids)
  kms_key_arn  = module.aws_kms[0].key_arn

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 5
      subnet_ids     = module.aws_vpc[0].private_subnet_ids
    }
  }

  tags = local.aws_tags
}

module "aws_alb" {
  source = "./modules/aws/alb"
  count  = var.deploy_aws ? 1 : 0

  name               = "${var.environment}-alb"
  subnet_ids         = module.aws_vpc[0].public_subnet_ids
  vpc_id             = module.aws_vpc[0].vpc_id
  security_group_ids = [module.aws_sg_web[0].sg_id]

  target_groups = {
    web = {
      port             = 80
      protocol         = "HTTP"
      health_check_path = "/health"
    }
  }

  create_http_listener = true
  tags                 = local.aws_tags
}

module "aws_cloudwatch" {
  source = "./modules/aws/cloudwatch"
  count  = var.deploy_aws ? 1 : 0

  log_groups = {
    "/app/${var.environment}/api" = { retention_in_days = 30 }
  }

  tags = local.aws_tags
}

# ─── AZURE ──────────────────────────────────────────────────────────────────

module "azure_vnet" {
  source = "./modules/azure/vnet"
  count  = var.deploy_azure ? 1 : 0

  vnet_name             = "${var.environment}-vnet"
  location              = var.azure_location
  resource_group_name   = var.azure_resource_group
  create_resource_group = true
  address_space         = [var.azure_vnet_cidr]

  subnets = {
    public  = { address_prefixes = [var.azure_public_subnet_cidr] }
    private = { address_prefixes = [var.azure_private_subnet_cidr] }
  }

  tags = local.azure_tags
}

module "azure_nsg" {
  source = "./modules/azure/nsg"
  count  = var.deploy_azure ? 1 : 0

  nsg_name            = "${var.environment}-web-nsg"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group
  subnet_ids          = [module.azure_vnet[0].subnet_ids["public"]]

  security_rules = {
    allow-http = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    allow-https = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = local.azure_tags
}

module "azure_keyvault" {
  source = "./modules/azure/keyvault"
  count  = var.deploy_azure ? 1 : 0

  key_vault_name      = "${var.environment}-kv-${substr(md5(var.azure_resource_group), 0, 6)}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group

  tags = local.azure_tags
}

module "azure_storage" {
  source = "./modules/azure/storage"
  count  = var.deploy_azure ? 1 : 0

  storage_account_name = "${var.environment}sa${substr(md5(var.azure_resource_group), 0, 8)}"
  location             = var.azure_location
  resource_group_name  = var.azure_resource_group

  containers = {
    app-data = { access_type = "private" }
    backups  = { access_type = "private" }
  }

  tags = local.azure_tags
}

module "azure_aks" {
  source = "./modules/azure/aks"
  count  = var.deploy_azure && var.deploy_aks ? 1 : 0

  cluster_name        = "${var.environment}-aks"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group

  default_node_pool = {
    vm_size    = "Standard_D2s_v3"
    node_count = 2
    subnet_id  = module.azure_vnet[0].subnet_ids["private"]
  }

  log_analytics_workspace_id = module.azure_monitor[0].log_analytics_workspace_id
  tags                       = local.azure_tags
}

module "azure_monitor" {
  source = "./modules/azure/monitor"
  count  = var.deploy_azure ? 1 : 0

  location                       = var.azure_location
  resource_group_name            = var.azure_resource_group
  create_log_analytics_workspace = true
  workspace_name                 = "${var.environment}-law"
  retention_in_days              = 30

  tags = local.azure_tags
}

# ─── GCP ────────────────────────────────────────────────────────────────────

module "gcp_vpc" {
  source = "./modules/gcp/vpc"
  count  = var.deploy_gcp ? 1 : 0

  network_name = "${var.environment}-vpc"
  project_id   = var.gcp_project_id
  region       = var.gcp_region
  create_nat   = true

  subnets = {
    "${var.environment}-subnet" = {
      ip_cidr_range = var.gcp_subnet_cidr
      region        = var.gcp_region
      secondary_ranges = [
        { range_name = "pods",     ip_cidr_range = "10.100.0.0/16" },
        { range_name = "services", ip_cidr_range = "10.101.0.0/16" }
      ]
    }
  }

  firewall_rules = {
    "${var.environment}-allow-http" = {
      allow         = [{ protocol = "tcp", ports = ["80", "443"] }]
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["web"]
    }
    "${var.environment}-allow-internal" = {
      allow         = [{ protocol = "tcp" }, { protocol = "udp" }, { protocol = "icmp" }]
      source_ranges = [var.gcp_subnet_cidr]
    }
  }
}

module "gcp_iam" {
  source = "./modules/gcp/iam"
  count  = var.deploy_gcp ? 1 : 0

  project_id = var.gcp_project_id

  service_accounts = {
    "${var.environment}-app-sa" = {
      display_name = "${var.environment} Application SA"
      roles        = ["roles/cloudsql.client", "roles/storage.objectAdmin"]
    }
    "${var.environment}-gke-sa" = {
      display_name = "${var.environment} GKE Node SA"
      roles        = ["roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/storage.objectViewer"]
    }
  }
}

module "gcp_kms" {
  source = "./modules/gcp/kms"
  count  = var.deploy_gcp ? 1 : 0

  key_ring_name = "${var.environment}-keyring"
  project_id    = var.gcp_project_id
  location      = var.gcp_region

  crypto_keys = {
    app-key = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s"
    }
  }
}

module "gcp_storage" {
  source = "./modules/gcp/storage"
  count  = var.deploy_gcp ? 1 : 0

  bucket_name        = "${var.environment}-app-${var.gcp_project_id}"
  project_id         = var.gcp_project_id
  location           = var.gcp_region
  versioning_enabled = true
  kms_key_name       = module.gcp_kms[0].crypto_key_ids["app-key"]

  labels = local.gcp_labels
}

module "gcp_cloudsql" {
  source = "./modules/gcp/cloudsql"
  count  = var.deploy_gcp ? 1 : 0

  instance_name     = "${var.environment}-postgres"
  project_id        = var.gcp_project_id
  region            = var.gcp_region
  database_version  = "POSTGRES_15"
  tier              = var.environment == "production" ? "db-custom-4-15360" : "db-custom-2-7680"
  availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"
  private_network   = module.gcp_vpc[0].network_self_link

  databases = {
    appdb = {}
  }

  labels = local.gcp_labels
}

module "gcp_gke" {
  source = "./modules/gcp/gke"
  count  = var.deploy_gcp && var.deploy_gke ? 1 : 0

  cluster_name = "${var.environment}-gke"
  project_id   = var.gcp_project_id
  location     = var.gcp_region
  network      = module.gcp_vpc[0].network_self_link
  subnetwork   = module.gcp_vpc[0].subnet_self_links["${var.environment}-subnet"]

  pods_secondary_range_name     = "pods"
  services_secondary_range_name = "services"

  node_pools = {
    general = {
      machine_type       = "e2-standard-2"
      node_count         = 2
      enable_autoscaling = true
      min_count          = 1
      max_count          = 5
      service_account    = module.gcp_iam[0].service_account_emails["${var.environment}-gke-sa"]
    }
  }

  labels = local.gcp_labels
}

module "gcp_pubsub" {
  source = "./modules/gcp/pubsub"
  count  = var.deploy_gcp ? 1 : 0

  project_id = var.gcp_project_id

  topics = {
    "${var.environment}-events" = {
      subscriptions = {
        "${var.environment}-events-sub" = {
          ack_deadline_seconds = 30
        }
      }
    }
  }

  labels = local.gcp_labels
}

locals {
  aws_tags = merge({
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.common_tags)

  azure_tags = merge({
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.common_tags)

  gcp_labels = merge({
    environment = lower(var.environment)
    managed_by  = "terraform"
  }, { for k, v in var.common_tags : lower(k) => lower(v) })
}
