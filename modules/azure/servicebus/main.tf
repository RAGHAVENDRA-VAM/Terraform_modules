resource "azurerm_servicebus_namespace" "this" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.sku == "Premium" ? var.capacity : null
  zone_redundant      = var.sku == "Premium" ? var.zone_redundant : false
  minimum_tls_version = "1.2"

  identity {
    type = "SystemAssigned"
  }

  tags = merge({ Name = var.namespace_name }, var.tags)
}

resource "azurerm_servicebus_queue" "this" {
  for_each     = var.queues
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                = lookup(each.value, "max_size_mb", 1024)
  default_message_ttl                  = lookup(each.value, "default_message_ttl", "P14D")
  lock_duration                        = lookup(each.value, "lock_duration", "PT1M")
  max_delivery_count                   = lookup(each.value, "max_delivery_count", 10)
  enable_dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_expiration", true)
  requires_duplicate_detection         = lookup(each.value, "requires_duplicate_detection", false)
  requires_session                     = lookup(each.value, "requires_session", false)
  partitioning_enabled                 = var.sku != "Premium" ? lookup(each.value, "partitioning_enabled", false) : false
}

resource "azurerm_servicebus_topic" "this" {
  for_each     = var.topics
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes        = lookup(each.value, "max_size_mb", 1024)
  default_message_ttl          = lookup(each.value, "default_message_ttl", "P14D")
  requires_duplicate_detection = lookup(each.value, "requires_duplicate_detection", false)
  partitioning_enabled         = var.sku != "Premium" ? lookup(each.value, "partitioning_enabled", false) : false
}

resource "azurerm_servicebus_subscription" "this" {
  for_each = {
    for item in flatten([
      for topic, cfg in var.topics : [
        for sub_name, sub_cfg in lookup(cfg, "subscriptions", {}) : {
          key      = "${topic}-${sub_name}"
          topic    = topic
          sub_name = sub_name
          sub_cfg  = sub_cfg
        }
      ]
    ]) : item.key => item
  }

  name               = each.value.sub_name
  topic_id           = azurerm_servicebus_topic.this[each.value.topic].id
  max_delivery_count = lookup(each.value.sub_cfg, "max_delivery_count", 10)
  lock_duration      = lookup(each.value.sub_cfg, "lock_duration", "PT1M")
  default_message_ttl = lookup(each.value.sub_cfg, "default_message_ttl", "P14D")
  dead_lettering_on_message_expiration = lookup(each.value.sub_cfg, "dead_lettering_on_expiration", true)
}
