# =============================================================================
# variables.tf — All configuration variables for the CloudEco GCP deployment.
# Values are supplied via terraform.tfvars.
# NEVER commit terraform.tfvars to version control.
# =============================================================================

variable "project_id" {
  description = "Your GCP project ID (e.g. fit5225-cloudeco)"
  type        = string
}

variable "region" {
  description = "GCP region — australia-southeast2 is Melbourne"
  type        = string
  default     = "australia-southeast2"
}

variable "zone" {
  description = "GCP zone within the region"
  type        = string
  default     = "australia-southeast2-a"
}

variable "machine_type" {
  description = "GCP machine type for all 3 nodes. e2-standard-4 = 4 vCPU, 16 GB RAM"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB per VM. 50GB recommended — ONNX image + OS + K8s binaries"
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key content (run: cat ~/.ssh/fit5225_oci.pub)"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key on your local machine (e.g. ~/.ssh/fit5225_oci)"
  type        = string
  default     = "~/.ssh/fit5225_oci"
}
