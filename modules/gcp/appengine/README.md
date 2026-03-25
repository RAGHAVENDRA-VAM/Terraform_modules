# GCP App Engine Module

Creates a GCP App Engine application with Standard or Flexible environment, traffic splitting, VPC connector, custom domains, and firewall rules. Equivalent to Azure App Service.

## Usage

### Standard Environment (Node.js)
```hcl
module "webapp" {
  source = "../../modules/gcp/appengine"

  project_id   = var.project_id
  create_app   = true
  location_id  = "us-central"
  service_name = "default"
  version_id   = "v1"
  runtime_type = "standard"
  runtime      = "nodejs20"
  instance_class = "F2"

  entrypoint = "node server.js"

  deployment_zip = {
    source_url = "https://storage.googleapis.com/${var.bucket}/app.zip"
  }

  env_variables = {
    NODE_ENV = "production"
    DB_HOST  = module.cloudsql.private_ip_address
  }

  scaling_type = "automatic"
  automatic_scaling = {
    min_instances          = 1
    max_instances          = 10
    target_cpu_utilization = 0.6
  }

  create_vpc_connector = true
  vpc_connector_cidr   = "10.8.0.0/28"
  network_name         = module.vpc.network_name
}
```

### Flexible Environment (Docker)
```hcl
module "webapp" {
  source = "../../modules/gcp/appengine"

  project_id    = var.project_id
  create_app    = false  # already created
  service_name  = "api"
  version_id    = "v2"
  runtime_type  = "flexible"
  runtime       = "custom"

  container_image = "gcr.io/${var.project_id}/myapp:latest"

  resources = {
    cpu       = 2
    memory_gb = 2.4
    disk_gb   = 20
  }

  scaling_type = "automatic"
  automatic_scaling = {
    min_instances          = 1
    max_instances          = 5
    target_cpu_utilization = 0.6
  }

  liveness_check  = { path = "/liveness" }
  readiness_check = { path = "/readiness" }

  service_account_email = module.iam.service_account_emails["app-sa"]
}
```

### Traffic Splitting (Blue/Green)
```hcl
module "webapp" {
  source = "../../modules/gcp/appengine"

  project_id   = var.project_id
  create_app   = false
  service_name = "default"
  version_id   = "v2"
  runtime_type = "standard"
  runtime      = "nodejs20"

  traffic_split = {
    v1 = 0.8
    v2 = 0.2
  }
  shard_by = "COOKIE"
}
```

## Supported Runtimes (Standard)
| Language | Runtime Value |
|----------|--------------|
| Node.js 20 | `nodejs20` |
| Python 3.12 | `python312` |
| Java 21 | `java21` |
| Go 1.22 | `go122` |
| PHP 8.2 | `php82` |
| Ruby 3.2 | `ruby32` |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| create_app | Create App Engine app | bool | true | no |
| location_id | App Engine location | string | us-central | no |
| service_name | Service name | string | default | no |
| runtime_type | standard or flexible | string | standard | no |
| runtime | Runtime identifier | string | nodejs20 | no |
| env_variables | Environment variables | map(string) | {} | no |
| scaling_type | automatic/basic/manual | string | automatic | no |
| traffic_split | Version traffic allocation | map(number) | {} | no |
| custom_domains | Custom domain names | list(string) | [] | no |

## Outputs
| Name | Description |
|------|-------------|
| app_url | Default app URL |
| service_url | Service-specific URL |
| version_url | Version-specific URL |
| vpc_connector_id | VPC connector ID |
