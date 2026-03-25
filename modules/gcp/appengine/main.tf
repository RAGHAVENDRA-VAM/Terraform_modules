# App Engine Application (one per project)
resource "google_app_engine_application" "this" {
  count         = var.create_app ? 1 : 0
  project       = var.project_id
  location_id   = var.location_id
  database_type = var.database_type

  dynamic "iap" {
    for_each = var.iap != null ? [var.iap] : []
    content {
      enabled              = true
      oauth2_client_id     = iap.value.oauth2_client_id
      oauth2_client_secret = iap.value.oauth2_client_secret
    }
  }

  dynamic "feature_settings" {
    for_each = var.split_health_checks != null ? [1] : []
    content {
      split_health_checks = var.split_health_checks
    }
  }
}

# Standard Environment Service (for Python, Node.js, Java, Go, PHP, Ruby)
resource "google_app_engine_standard_app_version" "this" {
  count      = var.runtime_type == "standard" ? 1 : 0
  project    = var.project_id
  service    = var.service_name
  version_id = var.version_id
  runtime    = var.runtime

  entrypoint {
    shell = var.entrypoint
  }

  deployment {
    dynamic "zip" {
      for_each = var.deployment_zip != null ? [var.deployment_zip] : []
      content {
        source_url  = zip.value.source_url
        files_count = lookup(zip.value, "files_count", null)
      }
    }

    dynamic "files" {
      for_each = var.deployment_files
      content {
        name       = files.key
        source_url = files.value.source_url
        sha1_sum   = lookup(files.value, "sha1_sum", null)
      }
    }
  }

  env_variables = var.env_variables

  dynamic "automatic_scaling" {
    for_each = var.scaling_type == "automatic" ? [var.automatic_scaling] : []
    content {
      max_concurrent_requests = lookup(automatic_scaling.value, "max_concurrent_requests", 10)
      max_idle_instances      = lookup(automatic_scaling.value, "max_idle_instances", 1)
      max_pending_latency     = lookup(automatic_scaling.value, "max_pending_latency", "30ms")
      min_idle_instances      = lookup(automatic_scaling.value, "min_idle_instances", 0)
      min_pending_latency     = lookup(automatic_scaling.value, "min_pending_latency", "30ms")

      dynamic "standard_scheduler_settings" {
        for_each = lookup(automatic_scaling.value, "target_cpu_utilization", null) != null ? [1] : []
        content {
          target_cpu_utilization        = lookup(automatic_scaling.value, "target_cpu_utilization", 0.6)
          target_throughput_utilization = lookup(automatic_scaling.value, "target_throughput_utilization", 0.6)
          min_instances                 = lookup(automatic_scaling.value, "min_instances", 0)
          max_instances                 = lookup(automatic_scaling.value, "max_instances", 10)
        }
      }
    }
  }

  dynamic "basic_scaling" {
    for_each = var.scaling_type == "basic" ? [var.basic_scaling] : []
    content {
      max_instances = lookup(basic_scaling.value, "max_instances", 5)
      idle_timeout  = lookup(basic_scaling.value, "idle_timeout", "5m")
    }
  }

  dynamic "manual_scaling" {
    for_each = var.scaling_type == "manual" ? [var.manual_scaling] : []
    content {
      instances = manual_scaling.value.instances
    }
  }

  instance_class = var.instance_class

  dynamic "vpc_access_connector" {
    for_each = var.vpc_connector_name != null ? [1] : []
    content {
      name = var.vpc_connector_name
    }
  }

  dynamic "handlers" {
    for_each = var.handlers
    content {
      url_regex                   = handlers.value.url_regex
      security_level              = lookup(handlers.value, "security_level", "SECURE_ALWAYS")
      login                       = lookup(handlers.value, "login", "LOGIN_OPTIONAL")
      auth_fail_action            = lookup(handlers.value, "auth_fail_action", "AUTH_FAIL_ACTION_REDIRECT")
      redirect_http_response_code = lookup(handlers.value, "redirect_http_response_code", "REDIRECT_HTTP_RESPONSE_CODE_301")

      dynamic "static_files" {
        for_each = lookup(handlers.value, "static_files", null) != null ? [handlers.value.static_files] : []
        content {
          path              = static_files.value.path
          upload_path_regex = static_files.value.upload_path_regex
        }
      }

      dynamic "script" {
        for_each = lookup(handlers.value, "script", null) != null ? [handlers.value.script] : []
        content {
          script_path = script.value.script_path
        }
      }
    }
  }

  delete_service_on_destroy = var.delete_service_on_destroy
  noop_on_destroy           = var.noop_on_destroy
}

# Flexible Environment Service (for custom runtimes / Docker)
resource "google_app_engine_flexible_app_version" "this" {
  count      = var.runtime_type == "flexible" ? 1 : 0
  project    = var.project_id
  service    = var.service_name
  version_id = var.version_id
  runtime    = var.runtime

  dynamic "entrypoint" {
    for_each = var.entrypoint != null ? [1] : []
    content {
      shell = var.entrypoint
    }
  }

  deployment {
    dynamic "container" {
      for_each = var.container_image != null ? [1] : []
      content {
        image = var.container_image
      }
    }

    dynamic "zip" {
      for_each = var.deployment_zip != null ? [var.deployment_zip] : []
      content {
        source_url  = zip.value.source_url
        files_count = lookup(zip.value, "files_count", null)
      }
    }
  }

  env_variables = var.env_variables

  resources {
    cpu       = lookup(var.resources, "cpu", 1)
    memory_gb = lookup(var.resources, "memory_gb", 0.6)
    disk_gb   = lookup(var.resources, "disk_gb", 10)
  }

  dynamic "automatic_scaling" {
    for_each = var.scaling_type == "automatic" ? [var.automatic_scaling] : []
    content {
      min_total_instances = lookup(automatic_scaling.value, "min_instances", 1)
      max_total_instances = lookup(automatic_scaling.value, "max_instances", 5)
      cool_down_period    = lookup(automatic_scaling.value, "cool_down_period", "120s")

      cpu_utilization {
        target_utilization = lookup(automatic_scaling.value, "target_cpu_utilization", 0.6)
      }
    }
  }

  dynamic "manual_scaling" {
    for_each = var.scaling_type == "manual" ? [var.manual_scaling] : []
    content {
      instances = manual_scaling.value.instances
    }
  }

  dynamic "liveness_check" {
    for_each = var.liveness_check != null ? [var.liveness_check] : []
    content {
      path              = liveness_check.value.path
      host              = lookup(liveness_check.value, "host", null)
      failure_threshold = lookup(liveness_check.value, "failure_threshold", 4)
      success_threshold = lookup(liveness_check.value, "success_threshold", 2)
      check_interval    = lookup(liveness_check.value, "check_interval", "30s")
      timeout           = lookup(liveness_check.value, "timeout", "4s")
      initial_delay     = lookup(liveness_check.value, "initial_delay", "300s")
    }
  }

  dynamic "readiness_check" {
    for_each = var.readiness_check != null ? [var.readiness_check] : []
    content {
      path              = readiness_check.value.path
      host              = lookup(readiness_check.value, "host", null)
      failure_threshold = lookup(readiness_check.value, "failure_threshold", 2)
      success_threshold = lookup(readiness_check.value, "success_threshold", 2)
      check_interval    = lookup(readiness_check.value, "check_interval", "5s")
      timeout           = lookup(readiness_check.value, "timeout", "4s")
      app_start_timeout = lookup(readiness_check.value, "app_start_timeout", "300s")
    }
  }

  dynamic "network" {
    for_each = var.network_name != null ? [1] : []
    content {
      name            = var.network_name
      subnetwork      = var.subnetwork_name
      instance_tag    = var.service_name
      forwarded_ports = var.forwarded_ports
    }
  }

  dynamic "vpc_access_connector" {
    for_each = var.vpc_connector_name != null ? [1] : []
    content {
      name = var.vpc_connector_name
    }
  }

  service_account       = var.service_account_email
  delete_service_on_destroy = var.delete_service_on_destroy
  noop_on_destroy           = var.noop_on_destroy
}

# Traffic Splitting
resource "google_app_engine_service_split_traffic" "this" {
  count   = length(var.traffic_split) > 0 ? 1 : 0
  project = var.project_id
  service = var.service_name

  migrate_traffic = var.migrate_traffic

  split {
    shard_by    = var.shard_by
    allocations = var.traffic_split
  }

  depends_on = [
    google_app_engine_standard_app_version.this,
    google_app_engine_flexible_app_version.this
  ]
}

# VPC Access Connector (for private VPC access)
resource "google_vpc_access_connector" "this" {
  count         = var.create_vpc_connector ? 1 : 0
  name          = "${var.service_name}-connector"
  project       = var.project_id
  region        = var.region
  network       = var.network_name
  ip_cidr_range = var.vpc_connector_cidr
  min_instances = lookup(var.vpc_connector_config, "min_instances", 2)
  max_instances = lookup(var.vpc_connector_config, "max_instances", 3)
  machine_type  = lookup(var.vpc_connector_config, "machine_type", "e2-micro")
}

# Custom Domain Mapping
resource "google_app_engine_domain_mapping" "this" {
  for_each    = toset(var.custom_domains)
  project     = var.project_id
  domain_name = each.value

  ssl_settings {
    ssl_management_type = "AUTOMATIC"
  }
}

# Firewall Rules
resource "google_app_engine_firewall_rule" "this" {
  for_each     = var.firewall_rules
  project      = var.project_id
  priority     = each.value.priority
  action       = each.value.action
  source_range = each.value.source_range
  description  = lookup(each.value, "description", "")
}
