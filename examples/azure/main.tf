terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

locals {
  location = "East US"
  rg_name  = "rg-dev-example"
  tags     = { Environment = "dev", ManagedBy = "Terraform" }
}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = local.location
  tags     = local.tags
}

module "vnet" {
  source = "../../modules/azure/vnet"

  vnet_name           = "dev-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = ["10.0.0.0/16"]
  subnets = {
    public  = { address_prefixes = ["10.0.1.0/24"] }
    private = { address_prefixes = ["10.0.11.0/24"] }
    aks     = { address_prefixes = ["10.0.21.0/24"] }
  }

  tags = local.tags
}

module "nsg" {
  source = "../../modules/azure/nsg"

  nsg_name            = "dev-web-nsg"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_ids          = [module.vnet.subnet_ids["public"]]

  security_rules = {
    allow-http  = { priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", destination_port_range = "80",  source_address_prefix = "*", destination_address_prefix = "*" }
    allow-https = { priority = 110, direction = "Inbound", access = "Allow", protocol = "Tcp", destination_port_range = "443", source_address_prefix = "*", destination_address_prefix = "*" }
  }

  tags = local.tags
}

module "keyvault" {
  source = "../../modules/azure/keyvault"

  key_vault_name      = "dev-kv-${substr(md5(local.rg_name), 0, 6)}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

module "storage" {
  source = "../../modules/azure/storage"

  storage_account_name = "devsa${substr(md5(local.rg_name), 0, 8)}"
  location             = local.location
  resource_group_name  = azurerm_resource_group.main.name

  containers = {
    app-data = { access_type = "private" }
    backups  = { access_type = "private" }
  }

  tags = local.tags
}

module "vm_web" {
  source = "../../modules/azure/vm"

  vm_name             = "dev-web-vm"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = "Standard_B2s"
  subnet_id           = module.vnet.subnet_ids["private"]
  admin_ssh_public_key = var.ssh_public_key
  tags                = local.tags
}

module "sql" {
  source = "../../modules/azure/sql"

  server_name                  = "dev-sqlserver-${substr(md5(local.rg_name), 0, 6)}"
  location                     = local.location
  resource_group_name          = azurerm_resource_group.main.name
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_password

  databases = {
    appdb = { sku_name = "S1", max_size_gb = 10 }
  }

  tags = local.tags
}

module "monitor" {
  source = "../../modules/azure/monitor"

  location                       = local.location
  resource_group_name            = azurerm_resource_group.main.name
  create_log_analytics_workspace = true
  workspace_name                 = "dev-law"
  tags                           = local.tags
}

module "servicebus" {
  source = "../../modules/azure/servicebus"

  namespace_name      = "dev-sb-${substr(md5(local.rg_name), 0, 6)}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name

  queues = {
    job-queue = { max_delivery_count = 5 }
  }

  topics = {
    events = {
      subscriptions = {
        processor = { max_delivery_count = 10 }
      }
    }
  }

  tags = local.tags
}

variable "ssh_public_key" {
  description = "SSH public key for Linux VM"
  type        = string
}

variable "sql_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

output "vnet_id"              { value = module.vnet.vnet_id }
output "vm_private_ip"        { value = module.vm_web.private_ip }
output "sql_server_fqdn"      { value = module.sql.server_fqdn }
output "key_vault_uri"        { value = module.keyvault.key_vault_uri }
output "storage_blob_endpoint"{ value = module.storage.primary_blob_endpoint }
