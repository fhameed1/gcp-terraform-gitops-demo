output "project_id" {
  description = "The GCP Project ID"
  value       = var.project_id
}

output "state_bucket_name" {
  description = "The name of the GCS bucket for Terraform remote state"
  value       = google_storage_bucket.tf_state.name
}

output "service_account_email" {
  description = "The email of the GitHub Actions CI/CD service account"
  value       = google_service_account.github_actions_sa.email
}

output "workload_identity_pool_name" {
  description = "The resource name of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_provider_name" {
  description = "The full provider resource name for GitHub Actions auth"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}
