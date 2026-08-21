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

  backend "gcs" {
    bucket = "tf-state-gitops-vigilant-cider-502720-m5-1021e058"
    prefix = "workload/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
