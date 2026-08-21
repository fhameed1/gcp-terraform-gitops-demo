variable "project_id" {
  description = "The GCP Project ID to deploy resources into"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "The target environment tier (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
