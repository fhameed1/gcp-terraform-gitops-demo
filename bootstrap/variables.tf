variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "The GitHub repository in the format owner/repo (e.g. fhameed1/gcp-terraform-gitops-demo)"
  type        = string
}
