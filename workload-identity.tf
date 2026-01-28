locals {
  aws_role_name        = "scanner"
  identity_pool_id     = "vanta-997096cb7c71843"
  identity_provider_id = "vanta-aws"
  subject_name         = "vanta-scanner"
  subject_uri          = "principal://iam.googleapis.com/projects/${google_project.vanta_scanner.number}/locations/global/workloadIdentityPools/${local.identity_pool_id}/subject/${local.subject_name}"
  aws_account_id       = "956993596390"
}

# Create the Workload Identity Pool
resource "google_iam_workload_identity_pool" "vanta_identity_pool" {
  depends_on                = [google_project_service.enabled_apis]
  project                   = google_project.vanta_scanner.project_id
  workload_identity_pool_id = local.identity_pool_id
  display_name              = "Vanta"
}
# Wait for the pool to be created
resource "time_sleep" "wait_for_pool_60s" {
  create_duration = "60s"
  depends_on      = [google_iam_workload_identity_pool.vanta_identity_pool]
  lifecycle {
    replace_triggered_by = [
      google_iam_workload_identity_pool.vanta_identity_pool,
    ]
  }
}
# Create the Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "vanta_identity_provider" {
  depends_on                         = [time_sleep.wait_for_pool_60s]
  project                            = google_project.vanta_scanner.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.vanta_identity_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = local.identity_provider_id
  display_name                       = "Vanta AWS"
  attribute_mapping = {
    "google.subject" = "'${local.subject_name}'"
    "attribute.arn"  = "assertion.arn"
  }
  attribute_condition = "attribute.arn.extract('assumed-role/{role}/') == '${local.aws_role_name}'"
  aws {
    account_id = local.aws_account_id
  }
}
