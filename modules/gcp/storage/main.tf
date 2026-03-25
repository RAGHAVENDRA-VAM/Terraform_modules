resource "google_storage_bucket" "this" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.location
  storage_class = var.storage_class
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true
  public_access_prevention    = var.public_access_prevention

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lookup(lifecycle_rule.value, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value, "age_days", null)
        num_newer_versions    = lookup(lifecycle_rule.value, "num_newer_versions", null)
        with_state            = lookup(lifecycle_rule.value, "with_state", null)
      }
    }
  }

  dynamic "cors" {
    for_each = var.cors_rules
    content {
      origin          = cors.value.origins
      method          = cors.value.methods
      response_header = lookup(cors.value, "response_headers", ["*"])
      max_age_seconds = lookup(cors.value, "max_age_seconds", 3600)
    }
  }

  dynamic "logging" {
    for_each = var.log_bucket != null ? [1] : []
    content {
      log_bucket        = var.log_bucket
      log_object_prefix = var.log_object_prefix
    }
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  labels = var.labels
}

resource "google_storage_bucket_iam_binding" "this" {
  for_each = var.iam_bindings

  bucket  = google_storage_bucket.this.name
  role    = each.key
  members = each.value
}
