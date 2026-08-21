terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# ------------------------------------------------------------------------------
# 1. Terraform State Bucket
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "tf_state" {
  name                        = "tf-state-gitops-${var.project_id}-${random_id.suffix.hex}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    managed-by  = "terraform-bootstrap"
    purpose     = "gitops-state"
    environment = "management"
  }
}

# ------------------------------------------------------------------------------
# 2. CI/CD Service Account for GitHub Actions
# ------------------------------------------------------------------------------
resource "google_service_account" "github_actions_sa" {
  account_id   = "sa-terraform-cicd"
  display_name = "GitHub Actions Terraform CI/CD Service Account"
  description  = "Assumed by GitHub Actions via Workload Identity Federation to manage GCP infrastructure"
}

# Grant the Service Account permissions on the Project
resource "google_project_iam_member" "sa_roles" {
  for_each = toset([
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant the Service Account permissions on the Terraform State Bucket
resource "google_storage_bucket_iam_member" "state_admin" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# ------------------------------------------------------------------------------
# 3. Workload Identity Federation (Keyless Auth from GitHub)
# ------------------------------------------------------------------------------
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool-${random_id.suffix.hex}"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions Workload Identity Federation"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC Provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository == '${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Allow GitHub Actions repo to impersonate the CI/CD Service Account
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}
