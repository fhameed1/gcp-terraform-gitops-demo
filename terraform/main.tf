# ------------------------------------------------------------------------------
# Stellar-Engine-Aligned Workload Enclave
# Demonstrating GitOps Infrastructure Provisioning with Zero-Trust Governance
# ------------------------------------------------------------------------------

resource "random_id" "workload_suffix" {
  byte_length = 3
}

# ------------------------------------------------------------------------------
# 1. Secure Cloud Storage Enclave (FedRAMP / Blueprint Baseline)
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "enclave_bucket" {
  name                        = "enclave-data-${var.environment}-${var.project_id}-${random_id.workload_suffix.hex}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 7
    }
  }

  labels = {
    environment = var.environment
    governance  = "gitops-automated"
    blueprint   = "stellar-engine"
    compliance  = "fedramp-baseline"
    managed_by  = "github-actions"
  }
}

# ------------------------------------------------------------------------------
# 2. Secure Isolated VPC Network Enclave
# ------------------------------------------------------------------------------
resource "google_compute_network" "enclave_vpc" {
  name                    = "vpc-enclave-${var.environment}-${random_id.workload_suffix.hex}"
  auto_create_subnetworks = false
  description             = "Dedicated secure enclave VPC managed solely via GitOps"
}

# Subnet with Private Google Access & VPC Flow Logs
resource "google_compute_subnetwork" "enclave_subnet" {
  name                     = "sb-enclave-${var.region}-${var.environment}"
  ip_cidr_range            = "10.10.1.0/24"
  region                   = var.region
  network                  = google_compute_network.enclave_vpc.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ------------------------------------------------------------------------------
# 3. Workload Identity & Enclave Service Account
# ------------------------------------------------------------------------------
resource "google_service_account" "workload_sa" {
  account_id   = "sa-app-enclave-${var.environment}"
  display_name = "Application Enclave Service Account (${var.environment})"
  description  = "Least-privilege service account used by workloads running inside the enclave"
}

# Grant workload SA read/write access strictly to its own bucket
resource "google_storage_bucket_iam_member" "workload_bucket_access" {
  bucket = google_storage_bucket.enclave_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.workload_sa.email}"
}

# ------------------------------------------------------------------------------
# 4. Enclave Security: Internal Traffic Ingress Rule (GitOps Change Example)
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_internal" {
  name        = "fw-allow-internal-${google_compute_network.enclave_vpc.name}"
  network     = google_compute_network.enclave_vpc.name
  description = "Allow internal communication within the enclave subnet"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["443", "8080"]
  }

  source_ranges = ["10.10.1.0/24"]
}
