resource "google_compute_network" "this" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  description             = var.description
}

resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  name                     = each.key
  project                  = var.project_id
  region                   = lookup(each.value, "region", var.region)
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = lookup(each.value, "private_ip_google_access", true)
  description              = lookup(each.value, "description", "")

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = lookup(each.value, "enable_flow_logs", false) ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_router" "this" {
  count   = var.create_nat ? 1 : 0
  name    = "${var.network_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  count                              = var.create_nat ? 1 : 0
  name                               = "${var.network_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.this[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "this" {
  for_each = var.firewall_rules

  name    = each.key
  project = var.project_id
  network = google_compute_network.this.id

  direction = lookup(each.value, "direction", "INGRESS")
  priority  = lookup(each.value, "priority", 1000)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", [])
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", [])
    }
  }

  source_ranges  = lookup(each.value, "source_ranges", null)
  target_tags    = lookup(each.value, "target_tags", null)
  source_tags    = lookup(each.value, "source_tags", null)
  description    = lookup(each.value, "description", "")
}
