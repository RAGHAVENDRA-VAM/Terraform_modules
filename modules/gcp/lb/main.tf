resource "google_compute_global_address" "this" {
  count   = var.lb_type == "global" ? 1 : 0
  name    = "${var.name}-ip"
  project = var.project_id
}

resource "google_compute_address" "this" {
  count   = var.lb_type == "regional" ? 1 : 0
  name    = "${var.name}-ip"
  project = var.project_id
  region  = var.region
}

resource "google_compute_health_check" "this" {
  for_each = var.health_checks

  name    = each.key
  project = var.project_id

  dynamic "http_health_check" {
    for_each = lookup(each.value, "type", "http") == "http" ? [1] : []
    content {
      port         = lookup(each.value, "port", 80)
      request_path = lookup(each.value, "request_path", "/")
    }
  }

  dynamic "https_health_check" {
    for_each = lookup(each.value, "type", "http") == "https" ? [1] : []
    content {
      port         = lookup(each.value, "port", 443)
      request_path = lookup(each.value, "request_path", "/")
    }
  }

  dynamic "tcp_health_check" {
    for_each = lookup(each.value, "type", "http") == "tcp" ? [1] : []
    content {
      port = lookup(each.value, "port", 80)
    }
  }

  check_interval_sec  = lookup(each.value, "check_interval_sec", 10)
  timeout_sec         = lookup(each.value, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value, "unhealthy_threshold", 3)
}

resource "google_compute_backend_service" "this" {
  for_each = var.backend_services

  name                  = each.key
  project               = var.project_id
  protocol              = lookup(each.value, "protocol", "HTTP")
  port_name             = lookup(each.value, "port_name", "http")
  load_balancing_scheme = var.lb_type == "global" ? "EXTERNAL_MANAGED" : "EXTERNAL"
  timeout_sec           = lookup(each.value, "timeout_sec", 30)
  enable_cdn            = lookup(each.value, "enable_cdn", false)

  health_checks = [google_compute_health_check.this[lookup(each.value, "health_check", keys(var.health_checks)[0])].id]

  dynamic "backend" {
    for_each = lookup(each.value, "backends", [])
    content {
      group           = backend.value.group
      balancing_mode  = lookup(backend.value, "balancing_mode", "UTILIZATION")
      capacity_scaler = lookup(backend.value, "capacity_scaler", 1.0)
    }
  }
}

resource "google_compute_url_map" "this" {
  name            = var.name
  project         = var.project_id
  default_service = google_compute_backend_service.this[var.default_backend_service].id

  dynamic "host_rule" {
    for_each = var.url_map_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.key
    }
  }

  dynamic "path_matcher" {
    for_each = var.url_map_rules
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_service.this[path_matcher.value.default_backend].id

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rules", [])
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.this[path_rule.value.backend].id
        }
      }
    }
  }
}

resource "google_compute_target_https_proxy" "this" {
  count            = var.create_https_proxy ? 1 : 0
  name             = "${var.name}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.this.id
  ssl_certificates = var.ssl_certificate_ids
}

resource "google_compute_target_http_proxy" "this" {
  count   = var.create_http_proxy ? 1 : 0
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.this.id
}

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.lb_type == "global" && var.create_https_proxy ? 1 : 0
  name                  = "${var.name}-https-rule"
  project               = var.project_id
  ip_address            = google_compute_global_address.this[0].address
  port_range            = "443"
  target                = google_compute_target_https_proxy.this[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_global_forwarding_rule" "http" {
  count                 = var.lb_type == "global" && var.create_http_proxy ? 1 : 0
  name                  = "${var.name}-http-rule"
  project               = var.project_id
  ip_address            = google_compute_global_address.this[0].address
  port_range            = "80"
  target                = google_compute_target_http_proxy.this[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
