locals {
  vanta_scanner_project_id = var.project_id == "" ? "${var.project_name}-${local.org_id}" : var.project_id
}

resource "google_project" "vanta_scanner" {
  org_id          = local.org_id
  deletion_policy = "ABANDON"
  name            = var.project_name
  project_id      = local.vanta_scanner_project_id
  billing_account = var.project_billing_account
}

# Wait for the project to be ready
resource "time_sleep" "wait_for_project_ready" {
  create_duration = "90s"
  depends_on      = [google_project.vanta_scanner]
  lifecycle {
    replace_triggered_by = [
      google_project.vanta_scanner,
    ]
  }
}

locals {
  required_apis = toset([
    "bigquery.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containeranalysis.googleapis.com",
    "essentialcontacts.googleapis.com",
    "firestore.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "storage-api.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com"
  ])
}

resource "google_project_service" "enabled_apis" {
  depends_on         = [time_sleep.wait_for_project_ready]
  disable_on_destroy = false
  for_each           = local.required_apis
  project            = google_project.vanta_scanner.project_id
  service            = each.key
}
