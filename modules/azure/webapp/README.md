# Azure Web App Module

Creates an Azure App Service Plan + Web App (Linux or Windows) with deployment slots, custom domains, autoscale, VNet integration, and diagnostic settings.

## Usage

### Linux Node.js App
```hcl
module "webapp" {
  source = "../../modules/azure/webapp"

  app_name            = "my-node-app"
  location            = "East US"
  resource_group_name = "rg-prod"
  sku_name            = "P1v3"
  os_type             = "Linux"

  application_stack = {
    node_version = "20-lts"
  }

  app_settings = {
    NODE_ENV        = "production"
    DATABASE_URL    = "@Microsoft.KeyVault(SecretUri=...)"
  }

  health_check_path = "/health"

  deployment_slots = {
    staging = { always_on = true }
  }

  autoscale = {
    min_count     = 1
    max_count     = 5
    default_count = 2
  }

  vnet_integration_subnet_id = module.vnet.subnet_ids["app"]
  tags = { Environment = "production" }
}
```

### Windows .NET App
```hcl
module "webapp" {
  source = "../../modules/azure/webapp"

  app_name            = "my-dotnet-app"
  location            = "East US"
  resource_group_name = "rg-prod"
  sku_name            = "P2v3"
  os_type             = "Windows"

  application_stack = {
    current_stack  = "dotnet"
    dotnet_version = "v8.0"
  }

  app_settings = {
    ASPNETCORE_ENVIRONMENT = "Production"
  }

  connection_strings = {
    DefaultConnection = {
      type  = "SQLAzure"
      value = "Server=...;Database=...;"
    }
  }

  tags = { Environment = "production" }
}
```

### Docker Container App
```hcl
module "webapp" {
  source = "../../modules/azure/webapp"

  app_name            = "my-container-app"
  location            = "East US"
  resource_group_name = "rg-prod"
  sku_name            = "P1v3"
  os_type             = "Linux"

  application_stack = {
    docker_image_name        = "myregistry.azurecr.io/myapp:latest"
    docker_registry_url      = "https://myregistry.azurecr.io"
    docker_registry_username = "myregistry"
    docker_registry_password = var.acr_password
  }

  tags = { Environment = "production" }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| app_name | Web app name (globally unique) | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| sku_name | App Service Plan SKU | string | P1v3 | no |
| os_type | Linux or Windows | string | Linux | no |
| application_stack | Runtime stack config | map(string) | null | no |
| app_settings | Environment variables | map(string) | {} | no |
| connection_strings | Connection strings | map(object) | {} | no |
| deployment_slots | Deployment slot configs | map(any) | {} | no |
| custom_hostnames | Custom domain names | list(string) | [] | no |
| autoscale | Autoscale configuration | map(any) | null | no |
| vnet_integration_subnet_id | VNet integration subnet | string | null | no |
| health_check_path | Health check path | string | null | no |

## Outputs
| Name | Description |
|------|-------------|
| web_app_id | Web app resource ID |
| default_hostname | Default hostname |
| default_site_url | Default HTTPS URL |
| identity_principal_id | Managed identity principal ID |
| outbound_ip_addresses | Outbound IPs |
