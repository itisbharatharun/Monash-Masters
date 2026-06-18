# =============================================================================
# variables.tf — All configuration variables for the CloudEco GCP deployment.
# Fill in terraform.tfvars with your actual values before running terraform apply.
# NEVER commit terraform.tfvars to version control — it contains your project ID.
# =============================================================================

variable "project_id" {
  description = "Your GCP project ID (find in GCP Console top bar, e.g. fit5225-cloudeco)"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources in"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone to deploy VM instances in"
  type        = string
  default     = "us-central1-f"
}

variable "machine_type" {
  description = "GCP machine type for all 3 nodes (4 vCPU, 16 GB RAM)"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB for each VM"
  type        = number
  default     = 25
}

variable "ssh_public_key" {
  description = "SSH public key string to authorise on all VMs. Run: cat ~/.ssh/fit5225_oci.pub"
  type        = string
}
