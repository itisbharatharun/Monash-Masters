# =============================================================================
# outputs.tf — Prints useful values after terraform apply completes
# =============================================================================

output "master_external_ip" {
  description = "External IP of the Kubernetes master node"
  value       = google_compute_address.master_ip.address
}

output "worker1_external_ip" {
  description = "External IP of Kubernetes worker node 1"
  value       = google_compute_address.worker1_ip.address
}

output "worker2_external_ip" {
  description = "External IP of Kubernetes worker node 2"
  value       = google_compute_address.worker2_ip.address
}

output "ssh_master" {
  description = "SSH command to connect to master node"
  value       = "ssh -i ~/.ssh/fit5225_oci ubuntu@${google_compute_address.master_ip.address}"
}

output "ssh_worker1" {
  description = "SSH command to connect to worker 1"
  value       = "ssh -i ~/.ssh/fit5225_oci ubuntu@${google_compute_address.worker1_ip.address}"
}

output "ssh_worker2" {
  description = "SSH command to connect to worker 2"
  value       = "ssh -i ~/.ssh/fit5225_oci ubuntu@${google_compute_address.worker2_ip.address}"
}
