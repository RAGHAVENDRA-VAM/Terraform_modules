terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

locals {
  region = "us-central1"
  zone   = "us-central1-a"
  labels = { environment = "dev", managed_by = "terraform" }
}

module "vpc" {
  source = "../../modules/gcp/vpc"

  network_name = "dev-vpc"
  project_id   = var.project_id
  region       = local.region
  create_nat   = true

  subnets = {
    dev-subnet = {
      ip_cidr_range = "10.0.0.0/24"
      region        = local.region
      secondary_ranges = [
        { range_name = "pods",     ip_cidr_range = "10.100.0.0/16" },
        { range_name = "services", ip_cidr_range = "10.101.0.0/16" }
      ]
    }
  }

  firewall_rules = {
    allow-http-https = {
      allow         = [{ protocol = "tcp", ports = ["80", "443"] }]
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["web"]
    }
    allow-ssh-iap = {
      allow         = [{ protocol = "tcp", ports = ["22"] }]
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["ssh"]
    }
  }
}

module "iam" {
  source = "../../modules/gcp/iam"

  project_id = var.project_id

  service_accounts = {
    dev-app-sa = {
      display_name = "Dev Application SA"
      roles        = ["roles/cloudsql.client", "roles/storage.objectAdmin", "roles/pubsub.publisher"]
    }
    dev-gke-sa = {
      display_name = "Dev GKE Node SA"
      roles        = ["roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/storage.objectViewer"]
    }
  }
}

module "kms" {
  source = "../../modules/gcp/kms"

  key_ring_name = "dev-keyring"
  project_id    = var.project_id
  location      = local.region

  crypto_keys = {
    app-key     = { purpose = "ENCRYPT_DECRYPT" }
    storage-key = { purpose = "ENCRYPT_DECRYPT" }
  }
}

module "storage" {
  source = "../../modules/gcp/storage"

  bucket_name        = "dev-app-${var.project_id}"
  project_id         = var.project_id
  location           = local.region
  versioning_enabled = true
  kms_key_name       = module.kms.crypto_key_ids["storage-key"]
  labels             = local.labels
}

module "cloudsql" {
  source = "../../modules/gcp/cloudsql"

  instance_name    = "dev-postgres"
  project_id       = var.project_id
  region           = local.region
  database_version = "POSTGRES_15"
  tier             = "db-custom-2-7680"
  private_network  = module.vpc.network_self_link

  databases = { appdb = {} }
  labels    = local.labels
}

module "gce_web" {
  source = "../../modules/gcp/gce"

  name           = "dev-web"
  project_id     = var.project_id
  zone           = local.zone
  machine_type   = "e2-medium"
  network        = module.vpc.network_self_link
  subnetwork     = module.vpc.subnet_self_links["dev-subnet"]
  network_tags   = ["web", "ssh"]
  instance_count = 2

  service_account_email = module.iam.service_account_emails["dev-app-sa"]
  labels                = local.labels
}

module "pubsub" {
  source = "../../modules/gcp/pubsub"

  project_id = var.project_id

  topics = {
    dev-events = {
      subscriptions = {
        dev-events-sub = { ack_deadline_seconds = 30 }
      }
    }
    dev-notifications = {
      subscriptions = {
        dev-notifications-sub = { ack_deadline_seconds = 20 }
      }
    }
  }

  labels = local.labels
}

module "monitoring" {
  source = "../../modules/gcp/monitoring"

  project_id = var.project_id

  notification_channels = {
    email-alerts = {
      type   = "email"
      labels = { email_address = "alerts@example.com" }
    }
  }

  uptime_checks = {
    web-uptime = {
      host = "example.com"
      path = "/health"
    }
  }
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

output "network_name"          { value = module.vpc.network_name }
output "cloudsql_connection"   { value = module.cloudsql.instance_connection_name }
output "storage_bucket_url"    { value = module.storage.bucket_url }
output "service_account_emails"{ value = module.iam.service_account_emails }
output "pubsub_topic_ids"      { value = module.pubsub.topic_ids }
