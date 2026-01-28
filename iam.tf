# Grant VantaOrganizationScanner role to the scanner principal at the organization level
resource "google_organization_iam_member" "vanta_org_binding" {
  depends_on = [google_iam_workload_identity_pool_provider.vanta_identity_provider]
  org_id     = local.org_id
  role       = "organizations/${local.org_id}/roles/VantaOrganizationScanner"
  member     = local.subject_uri
}

resource "google_organization_iam_custom_role" "vanta_project_scanner_role" {
  # Creates the VantaProjectScanner role in the org
  org_id      = local.org_id
  role_id     = "VantaProjectScanner"
  title       = "Vanta Project Scanner"
  description = "Role for listing project resources with configuration metadata"
  permissions = [
    "resourcemanager.projects.get",
    "bigquery.datasets.get",
    "compute.instances.get",
    "compute.instances.getEffectiveFirewalls",
    "compute.subnetworks.get",
    "pubsub.topics.get",
    "storage.buckets.get",
    "cloudasset.assets.searchAllResources"
  ]
}

# These permissions on the organization are optional
# If omitted, we will not be able to fetch essential contacts at the organization level and inherited roles and their bindings
resource "google_organization_iam_custom_role" "vanta_org_scanner_role" {
  org_id      = local.org_id
  role_id     = "VantaOrganizationScanner"
  title       = "Vanta Organization Scanner"
  description = "Role for listing inherited IAM policies"
  permissions = [
    "essentialcontacts.contacts.list",
    "iam.roles.list",
    "resourcemanager.organizations.getIamPolicy",
    "resourcemanager.folders.getIamPolicy"
  ]
}

# Grant VantaProjectScanner role to the scanner principal
resource "google_project_iam_member" "vanta_project_bindings" {
  for_each = toset(var.linked_project_ids)

  project = each.value
  role    = google_organization_iam_custom_role.vanta_project_scanner_role.id
  member  = local.subject_uri
}
# Grant iam.securityReviewer role to the scanner principal
resource "google_project_iam_member" "vanta_scanner_iam_security_reviewer" {
  for_each = toset(var.linked_project_ids)

  project = each.value
  role    = "roles/iam.securityReviewer"
  member  = local.subject_uri
}

# Wait for IAM propagation
resource "time_sleep" "wait_for_iam_propagation" {
  create_duration = "90s"
  depends_on = [
    google_project_iam_member.vanta_project_bindings,
    google_project_iam_member.vanta_scanner_iam_security_reviewer,
  ]
  lifecycle {
    replace_triggered_by = [
      google_project_iam_member.vanta_project_bindings,
      google_project_iam_member.vanta_scanner_iam_security_reviewer,
    ]
  }
}
