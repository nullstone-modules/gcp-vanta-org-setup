output "vanta_gcp_project_id" {
  value = google_project.vanta_scanner.project_id
}

output "vanta_gcp_project_number" {
  value = google_project.vanta_scanner.number
}

output "vanta_project_role_id" {
  value = google_organization_iam_custom_role.vanta_project_scanner_role.id
}

output "workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.vanta_identity_pool.workload_identity_pool_id
}

output "workload_identity_provider_id" {
  value = google_iam_workload_identity_pool_provider.vanta_identity_provider.workload_identity_pool_provider_id
}

output "workload_identity_subject_name" {
  value = local.subject_name
}

output "workload_identity_subject_uri" {
  value = local.subject_uri
}
