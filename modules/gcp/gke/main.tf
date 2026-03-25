resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.location

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = lookup(cidr_blocks.value, "display_name", "")
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = !var.enable_http_load_balancing
    }
    horizontal_pod_autoscaling {
      disabled = !var.enable_horizontal_pod_autoscaling
    }
    network_policy_config {
      disabled = !var.enable_network_policy
    }
  }

  network_policy {
    enabled  = var.enable_network_policy
    provider = var.enable_network_policy ? "CALICO" : "PROVIDER_UNSPECIFIED"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  min_master_version = var.min_master_version

  resource_labels = var.labels
}

resource "google_container_node_pool" "this" {
  for_each = var.node_pools

  name     = each.key
  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.this.name

  node_count = lookup(each.value, "enable_autoscaling", false) ? null : lookup(each.value, "node_count", 1)

  dynamic "autoscaling" {
    for_each = lookup(each.value, "enable_autoscaling", false) ? [1] : []
    content {
      min_node_count = lookup(each.value, "min_count", 1)
      max_node_count = lookup(each.value, "max_count", 3)
    }
  }

  node_config {
    machine_type    = lookup(each.value, "machine_type", "e2-medium")
    disk_size_gb    = lookup(each.value, "disk_size_gb", 50)
    disk_type       = lookup(each.value, "disk_type", "pd-ssd")
    image_type      = lookup(each.value, "image_type", "COS_CONTAINERD")
    service_account = lookup(each.value, "service_account", null)
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels          = lookup(each.value, "labels", {})
    tags            = lookup(each.value, "tags", [])

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  upgrade_settings {
    max_surge       = lookup(each.value, "max_surge", 1)
    max_unavailable = lookup(each.value, "max_unavailable", 0)
  }
}
