resource "google_pubsub_topic" "this" {
  for_each = var.topics

  name    = each.key
  project = var.project_id
  labels  = var.labels

  dynamic "message_storage_policy" {
    for_each = lookup(each.value, "allowed_regions", null) != null ? [1] : []
    content {
      allowed_persistence_regions = each.value.allowed_regions
    }
  }

  dynamic "schema_settings" {
    for_each = lookup(each.value, "schema_name", null) != null ? [1] : []
    content {
      schema   = "projects/${var.project_id}/schemas/${each.value.schema_name}"
      encoding = lookup(each.value, "schema_encoding", "JSON")
    }
  }

  message_retention_duration = lookup(each.value, "message_retention_duration", null)
  kms_key_name               = lookup(each.value, "kms_key_name", null)
}

resource "google_pubsub_subscription" "this" {
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

  name    = each.value.sub_name
  project = var.project_id
  topic   = google_pubsub_topic.this[each.value.topic].id
  labels  = var.labels

  ack_deadline_seconds       = lookup(each.value.sub_cfg, "ack_deadline_seconds", 20)
  message_retention_duration = lookup(each.value.sub_cfg, "message_retention_duration", "604800s")
  retain_acked_messages      = lookup(each.value.sub_cfg, "retain_acked_messages", false)

  dynamic "push_config" {
    for_each = lookup(each.value.sub_cfg, "push_endpoint", null) != null ? [1] : []
    content {
      push_endpoint = each.value.sub_cfg.push_endpoint
    }
  }

  dynamic "dead_letter_policy" {
    for_each = lookup(each.value.sub_cfg, "dead_letter_topic", null) != null ? [1] : []
    content {
      dead_letter_topic     = "projects/${var.project_id}/topics/${each.value.sub_cfg.dead_letter_topic}"
      max_delivery_attempts = lookup(each.value.sub_cfg, "max_delivery_attempts", 5)
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value.sub_cfg, "retry_policy", null) != null ? [1] : []
    content {
      minimum_backoff = lookup(each.value.sub_cfg.retry_policy, "minimum_backoff", "10s")
      maximum_backoff = lookup(each.value.sub_cfg.retry_policy, "maximum_backoff", "600s")
    }
  }

  expiration_policy {
    ttl = lookup(each.value.sub_cfg, "expiration_ttl", "")
  }
}

resource "google_pubsub_topic_iam_binding" "this" {
  for_each = {
    for item in flatten([
      for topic, cfg in var.topics : [
        for role, members in lookup(cfg, "iam_bindings", {}) : {
          key     = "${topic}-${role}"
          topic   = topic
          role    = role
          members = members
        }
      ]
    ]) : item.key => item
  }

  project = var.project_id
  topic   = google_pubsub_topic.this[each.value.topic].name
  role    = each.value.role
  members = each.value.members
}
