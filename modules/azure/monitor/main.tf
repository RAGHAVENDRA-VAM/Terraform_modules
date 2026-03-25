resource "azurerm_log_analytics_workspace" "this" {
  count               = var.create_log_analytics_workspace ? 1 : 0
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.workspace_sku
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "this" {
  for_each            = var.action_groups
  name                = each.key
  resource_group_name = var.resource_group_name
  short_name          = substr(each.key, 0, 12)

  dynamic "email_receiver" {
    for_each = lookup(each.value, "email_receivers", [])
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  dynamic "webhook_receiver" {
    for_each = lookup(each.value, "webhook_receivers", [])
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each            = var.metric_alerts
  name                = each.key
  resource_group_name = var.resource_group_name
  scopes              = each.value.scopes
  description         = lookup(each.value, "description", "")
  severity            = lookup(each.value, "severity", 2)
  frequency           = lookup(each.value, "frequency", "PT5M")
  window_size         = lookup(each.value, "window_size", "PT15M")

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  dynamic "action" {
    for_each = lookup(each.value, "action_group_names", [])
    content {
      action_group_id = azurerm_monitor_action_group.this[action.value].id
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                       = each.key
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.this[0].id : lookup(each.value, "log_analytics_workspace_id", null)

  dynamic "enabled_log" {
    for_each = lookup(each.value, "log_categories", [])
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(each.value, "metric_categories", ["AllMetrics"])
    content {
      category = metric.value
    }
  }
}
