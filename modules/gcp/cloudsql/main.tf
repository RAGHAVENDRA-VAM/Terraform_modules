resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size_gb
    disk_autoresize   = var.disk_autoresize

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.retained_backups
      }
    }

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = var.private_network
      require_ssl                                   = var.require_ssl
      enable_private_path_for_google_cloud_services = true

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.labels
  }
}

resource "google_sql_database" "this" {
  for_each = var.databases

  name     = each.key
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  charset  = lookup(each.value, "charset", null)
  collation = lookup(each.value, "collation", null)
}

resource "google_sql_user" "this" {
  for_each = var.users

  name     = each.key
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  password = each.value.password
  host     = lookup(each.value, "host", null)
}

resource "google_sql_database_instance" "replicas" {
  for_each = var.read_replicas

  name                 = "${var.instance_name}-replica-${each.key}"
  project              = var.project_id
  region               = lookup(each.value, "region", var.region)
  database_version     = var.database_version
  master_instance_name = google_sql_database_instance.this.name
  deletion_protection  = var.deletion_protection

  settings {
    tier              = lookup(each.value, "tier", var.tier)
    availability_type = "ZONAL"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = var.private_network
      require_ssl     = var.require_ssl
    }

    user_labels = var.labels
  }
}
