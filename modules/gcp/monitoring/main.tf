resource "google_monitoring_notification_channel" "this" {
  for_each = var.notification_channels

  display_name = each.key
  project      = var.project_id
  type         = each.value.type
  labels       = each.value.labels
  enabled      = lookup(each.value, "enabled", true)
}

resource "google_monitoring_alert_policy" "this" {
  for_each = var.alert_policies

  display_name = each.key
  project      = var.project_id
  combiner     = lookup(each.value, "combiner", "OR")
  enabled      = lookup(each.value, "enabled", true)

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name
      condition_threshold {
        filter          = conditions.value.filter
        comparison      = conditions.value.comparison
        threshold_value = conditions.value.threshold_value
        duration        = lookup(conditions.value, "duration", "60s")
        aggregations {
          alignment_period   = lookup(conditions.value, "alignment_period", "60s")
          per_series_aligner = lookup(conditions.value, "per_series_aligner", "ALIGN_MEAN")
        }
      }
    }
  }

  notification_channels = [
    for ch in lookup(each.value, "notification_channels", []) :
    google_monitoring_notification_channel.this[ch].name
  ]

  documentation {
    content   = lookup(each.value, "documentation", "")
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_uptime_check_config" "this" {
  for_each = var.uptime_checks

  display_name = each.key
  project      = var.project_id
  timeout      = lookup(each.value, "timeout", "10s")
  period       = lookup(each.value, "period", "60s")

  http_check {
    path         = lookup(each.value, "path", "/")
    port         = lookup(each.value, "port", 443)
    use_ssl      = lookup(each.value, "use_ssl", true)
    validate_ssl = lookup(each.value, "validate_ssl", true)
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = each.value.host
    }
  }
}

resource "google_logging_metric" "this" {
  for_each = var.log_metrics

  name    = each.key
  project = var.project_id
  filter  = each.value.filter

  metric_descriptor {
    metric_kind = lookup(each.value, "metric_kind", "DELTA")
    value_type  = lookup(each.value, "value_type", "INT64")
    unit        = lookup(each.value, "unit", "1")
  }
}
