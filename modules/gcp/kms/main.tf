resource "google_kms_key_ring" "this" {
  name     = var.key_ring_name
  project  = var.project_id
  location = var.location
}

resource "google_kms_crypto_key" "this" {
  for_each = var.crypto_keys

  name            = each.key
  key_ring        = google_kms_key_ring.this.id
  purpose         = lookup(each.value, "purpose", "ENCRYPT_DECRYPT")
  rotation_period = lookup(each.value, "rotation_period", "7776000s")

  version_template {
    algorithm        = lookup(each.value, "algorithm", "GOOGLE_SYMMETRIC_ENCRYPTION")
    protection_level = lookup(each.value, "protection_level", "SOFTWARE")
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_binding" "this" {
  for_each = {
    for item in flatten([
      for key, cfg in var.crypto_keys : [
        for role, members in lookup(cfg, "iam_bindings", {}) : {
          key     = "${key}-${role}"
          key_name = key
          role    = role
          members = members
        }
      ]
    ]) : item.key => item
  }

  crypto_key_id = google_kms_crypto_key.this[each.value.key_name].id
  role          = each.value.role
  members       = each.value.members
}
