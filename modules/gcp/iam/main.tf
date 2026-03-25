resource "google_service_account" "this" {
  for_each = var.service_accounts

  account_id   = each.key
  display_name = lookup(each.value, "display_name", each.key)
  description  = lookup(each.value, "description", "")
  project      = var.project_id
}

resource "google_project_iam_member" "service_account" {
  for_each = {
    for item in flatten([
      for sa, cfg in var.service_accounts : [
        for role in lookup(cfg, "roles", []) : {
          key  = "${sa}-${role}"
          sa   = sa
          role = role
        }
      ]
    ]) : item.key => item
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.this[each.value.sa].email}"
}

resource "google_service_account_iam_binding" "workload_identity" {
  for_each = {
    for sa, cfg in var.service_accounts : sa => cfg
    if lookup(cfg, "workload_identity_namespace", null) != null
  }

  service_account_id = google_service_account.this[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${each.value.workload_identity_namespace}/${lookup(each.value, "k8s_service_account", each.key)}]"
  ]
}

resource "google_project_iam_member" "custom" {
  for_each = {
    for item in flatten([
      for member, roles in var.project_iam_bindings : [
        for role in roles : {
          key    = "${member}-${role}"
          member = member
          role   = role
        }
      ]
    ]) : item.key => item
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_custom_role" "this" {
  for_each = var.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = lookup(each.value, "description", "")
  permissions = each.value.permissions
  project     = var.project_id
}
