# App Service Plan
resource "azurerm_service_plan" "this" {
  name                = "${var.app_name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name
  worker_count        = var.worker_count
  zone_balancing_enabled = var.zone_balancing_enabled
  tags                = merge({ Name = "${var.app_name}-plan" }, var.tags)
}

# Linux Web App
resource "azurerm_linux_web_app" "this" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  client_affinity_enabled = var.client_affinity_enabled

  site_config {
    always_on                               = var.always_on
    ftps_state                              = "Disabled"
    http2_enabled                           = true
    minimum_tls_version                     = "1.2"
    health_check_path                       = var.health_check_path
    health_check_eviction_time_in_min       = var.health_check_path != null ? 5 : null
    worker_count                            = var.site_worker_count

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        docker_image_name        = lookup(application_stack.value, "docker_image_name", null)
        docker_registry_url      = lookup(application_stack.value, "docker_registry_url", null)
        docker_registry_username = lookup(application_stack.value, "docker_registry_username", null)
        docker_registry_password = lookup(application_stack.value, "docker_registry_password", null)
        dotnet_version           = lookup(application_stack.value, "dotnet_version", null)
        java_version             = lookup(application_stack.value, "java_version", null)
        java_server              = lookup(application_stack.value, "java_server", null)
        java_server_version      = lookup(application_stack.value, "java_server_version", null)
        node_version             = lookup(application_stack.value, "node_version", null)
        php_version              = lookup(application_stack.value, "php_version", null)
        python_version           = lookup(application_stack.value, "python_version", null)
        ruby_version             = lookup(application_stack.value, "ruby_version", null)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name       = ip_restriction.value.name
        ip_address = lookup(ip_restriction.value, "ip_address", null)
        service_tag = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "subnet_id", null)
        priority   = ip_restriction.value.priority
        action     = lookup(ip_restriction.value, "action", "Allow")
      }
    }

    dynamic "cors" {
      for_each = var.cors != null ? [var.cors] : []
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = lookup(cors.value, "support_credentials", false)
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  identity {
    type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_app_settings) > 0 || length(var.sticky_connection_string_names) > 0 ? [1] : []
    content {
      app_setting_names       = var.sticky_app_settings
      connection_string_names = var.sticky_connection_string_names
    }
  }

  dynamic "logs" {
    for_each = var.enable_logging ? [1] : []
    content {
      detailed_error_messages = true
      failed_request_tracing  = true
      http_logs {
        retention_in_days = var.log_retention_days
      }
    }
  }

  dynamic "backup" {
    for_each = var.backup_storage_url != null ? [1] : []
    content {
      name                = "${var.app_name}-backup"
      storage_account_url = var.backup_storage_url
      schedule {
        frequency_interval       = var.backup_frequency_interval
        frequency_unit           = var.backup_frequency_unit
        retention_period_days    = var.backup_retention_days
        keep_at_least_one_backup = true
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings != null ? [var.auth_settings] : []
    content {
      auth_enabled           = true
      require_authentication = lookup(auth_settings.value, "require_authentication", true)
      unauthenticated_action = lookup(auth_settings.value, "unauthenticated_action", "RedirectToLoginPage")

      login {
        token_store_enabled = lookup(auth_settings.value, "token_store_enabled", true)
      }

      dynamic "active_directory_v2" {
        for_each = lookup(auth_settings.value, "aad", null) != null ? [auth_settings.value.aad] : []
        content {
          client_id                  = active_directory_v2.value.client_id
          tenant_auth_endpoint       = active_directory_v2.value.tenant_auth_endpoint
          client_secret_setting_name = lookup(active_directory_v2.value, "client_secret_setting_name", null)
        }
      }
    }
  }

  virtual_network_subnet_id = var.vnet_integration_subnet_id

  tags = merge({ Name = var.app_name }, var.tags)
}

# Windows Web App
resource "azurerm_windows_web_app" "this" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  client_affinity_enabled = var.client_affinity_enabled

  site_config {
    always_on           = var.always_on
    ftps_state          = "Disabled"
    http2_enabled       = true
    minimum_tls_version = "1.2"
    health_check_path   = var.health_check_path

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        current_stack             = lookup(application_stack.value, "current_stack", null)
        dotnet_version            = lookup(application_stack.value, "dotnet_version", null)
        java_version              = lookup(application_stack.value, "java_version", null)
        java_container            = lookup(application_stack.value, "java_container", null)
        java_container_version    = lookup(application_stack.value, "java_container_version", null)
        node_version              = lookup(application_stack.value, "node_version", null)
        php_version               = lookup(application_stack.value, "php_version", null)
        python                    = lookup(application_stack.value, "python", false)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name       = ip_restriction.value.name
        ip_address = lookup(ip_restriction.value, "ip_address", null)
        service_tag = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "subnet_id", null)
        priority   = ip_restriction.value.priority
        action     = lookup(ip_restriction.value, "action", "Allow")
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  identity {
    type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  virtual_network_subnet_id = var.vnet_integration_subnet_id

  tags = merge({ Name = var.app_name }, var.tags)
}

locals {
  web_app_id       = var.os_type == "Linux" ? try(azurerm_linux_web_app.this[0].id, null) : try(azurerm_windows_web_app.this[0].id, null)
  web_app_hostname = var.os_type == "Linux" ? try(azurerm_linux_web_app.this[0].default_hostname, null) : try(azurerm_windows_web_app.this[0].default_hostname, null)
  web_app_identity = var.os_type == "Linux" ? try(azurerm_linux_web_app.this[0].identity, []) : try(azurerm_windows_web_app.this[0].identity, [])
}

# Deployment Slots
resource "azurerm_linux_web_app_slot" "this" {
  for_each    = var.os_type == "Linux" ? var.deployment_slots : {}
  name        = each.key
  app_service_id = azurerm_linux_web_app.this[0].id

  site_config {
    always_on           = lookup(each.value, "always_on", false)
    health_check_path   = var.health_check_path
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    http2_enabled       = true
  }

  app_settings              = lookup(each.value, "app_settings", var.app_settings)
  virtual_network_subnet_id = var.vnet_integration_subnet_id
  tags                      = var.tags
}

resource "azurerm_windows_web_app_slot" "this" {
  for_each    = var.os_type == "Windows" ? var.deployment_slots : {}
  name        = each.key
  app_service_id = azurerm_windows_web_app.this[0].id

  site_config {
    always_on           = lookup(each.value, "always_on", false)
    health_check_path   = var.health_check_path
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    http2_enabled       = true
  }

  app_settings = lookup(each.value, "app_settings", var.app_settings)
  tags         = var.tags
}

# Custom Hostname Binding
resource "azurerm_app_service_custom_hostname_binding" "this" {
  for_each            = toset(var.custom_hostnames)
  hostname            = each.value
  app_service_name    = var.app_name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_linux_web_app.this, azurerm_windows_web_app.this]
}

# Managed Certificate for custom hostnames
resource "azurerm_app_service_managed_certificate" "this" {
  for_each                   = toset(var.custom_hostnames)
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.this[each.key].id
}

resource "azurerm_app_service_certificate_binding" "this" {
  for_each                  = toset(var.custom_hostnames)
  hostname_binding_id       = azurerm_app_service_custom_hostname_binding.this[each.key].id
  certificate_id            = azurerm_app_service_managed_certificate.this[each.key].id
  ssl_state                 = "SniEnabled"
}

# Autoscale Settings
resource "azurerm_monitor_autoscale_setting" "this" {
  count               = var.autoscale != null ? 1 : 0
  name                = "${var.app_name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.this.id

  profile {
    name = "default"

    capacity {
      default = lookup(var.autoscale, "default_count", 1)
      minimum = lookup(var.autoscale, "min_count", 1)
      maximum = lookup(var.autoscale, "max_count", 5)
    }

    dynamic "rule" {
      for_each = lookup(var.autoscale, "scale_out_rules", [
        {
          metric_name      = "CpuPercentage"
          operator         = "GreaterThan"
          threshold        = 75
          direction        = "Increase"
          change_count     = 1
          cooldown_minutes = 5
        }
      ])
      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = azurerm_service_plan.this.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = rule.value.operator
          threshold          = rule.value.threshold
        }
        scale_action {
          direction = rule.value.direction
          type      = "ChangeCount"
          value     = lookup(rule.value, "change_count", 1)
          cooldown  = "PT${lookup(rule.value, "cooldown_minutes", 5)}M"
        }
      }
    }

    dynamic "rule" {
      for_each = lookup(var.autoscale, "scale_in_rules", [
        {
          metric_name      = "CpuPercentage"
          operator         = "LessThan"
          threshold        = 25
          direction        = "Decrease"
          change_count     = 1
          cooldown_minutes = 10
        }
      ])
      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = azurerm_service_plan.this.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = rule.value.operator
          threshold          = rule.value.threshold
        }
        scale_action {
          direction = rule.value.direction
          type      = "ChangeCount"
          value     = lookup(rule.value, "change_count", 1)
          cooldown  = "PT${lookup(rule.value, "cooldown_minutes", 10)}M"
        }
      }
    }
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "${var.app_name}-diag"
  target_resource_id         = local.web_app_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceAuditLogs" }

  metric {
    category = "AllMetrics"
  }
}
