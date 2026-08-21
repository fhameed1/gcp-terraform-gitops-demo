output "enclave_bucket_name" {
  description = "The globally unique name of the provisioned secure GCS bucket"
  value       = google_storage_bucket.enclave_bucket.name
}

output "enclave_bucket_url" {
  description = "The URL to the provisioned GCS bucket"
  value       = google_storage_bucket.enclave_bucket.url
}

output "enclave_vpc_name" {
  description = "The name of the secure enclave VPC"
  value       = google_compute_network.enclave_vpc.name
}

output "enclave_subnet_cidr" {
  description = "The CIDR block of the secure subnet"
  value       = google_compute_subnetwork.enclave_subnet.ip_cidr_range
}

output "workload_service_account" {
  description = "The identity of the workload service account"
  value       = google_service_account.workload_sa.email
}
