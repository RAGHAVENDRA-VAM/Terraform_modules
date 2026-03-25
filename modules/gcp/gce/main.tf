resource "google_compute_instance" "this" {
  count        = var.instance_count
  name         = var.instance_count > 1 ? "${var.name}-${count.index + 1}" : var.name
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  description  = var.description

  tags   = var.network_tags
  labels = merge({ name = var.name }, var.labels)

  boot_disk {
    initialize_params {
      image  = var.boot_disk_image
      size   = var.boot_disk_size_gb
      type   = var.boot_disk_type
    }
    auto_delete = var.boot_disk_auto_delete
  }

  dynamic "attached_disk" {
    for_each = var.additional_disks
    content {
      source      = google_compute_disk.this[attached_disk.key].self_link
      device_name = attached_disk.key
      mode        = lookup(attached_disk.value, "mode", "READ_WRITE")
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.create_public_ip ? [1] : []
      content {
        nat_ip = var.static_ip
      }
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  metadata = merge(
    var.metadata,
    var.startup_script != null ? { startup-script = var.startup_script } : {}
  )

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    on_host_maintenance = var.preemptible ? "TERMINATE" : "MIGRATE"
    automatic_restart   = var.preemptible ? false : true
    preemptible         = var.preemptible
  }

  allow_stopping_for_update = true
}

resource "google_compute_disk" "this" {
  for_each = var.additional_disks

  name    = "${var.name}-${each.key}"
  project = var.project_id
  zone    = var.zone
  type    = lookup(each.value, "type", "pd-ssd")
  size    = each.value.size_gb
  labels  = var.labels
}
