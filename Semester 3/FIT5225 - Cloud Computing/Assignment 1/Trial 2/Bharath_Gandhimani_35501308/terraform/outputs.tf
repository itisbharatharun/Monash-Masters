# =============================================================================
# outputs.tf — Prints useful connection info after terraform apply completes.
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
  description = "SSH command to connect to worker node 1"
  value       = "ssh -i ~/.ssh/fit5225_oci ubuntu@${google_compute_address.worker1_ip.address}"
}

output "ssh_worker2" {
  description = "SSH command to connect to worker node 2"
  value       = "ssh -i ~/.ssh/fit5225_oci ubuntu@${google_compute_address.worker2_ip.address}"
}

output "api_endpoint" {
  description = "CloudEco Wildlife API endpoint (after deploying K8s manifests)"
  value       = "http://${google_compute_address.master_ip.address}:30503"
}

output "next_steps" {
  description = "Commands to run after terraform apply completes"
  value       = <<-EOT
    --- NEXT STEPS ---
    1. Verify cluster is healthy:
       ssh -i ~/.ssh/fit5225_oci ubuntu@${google_compute_address.master_ip.address}
       kubectl get nodes

    2. Deploy the application:
       kubectl apply -f deployment.yaml
       kubectl apply -f service.yaml

    3. Scale replicas (e.g. 4 pods):
       kubectl scale deployment wildlife-detector --replicas=4

    4. Access the API:
       http://${google_compute_address.master_ip.address}:30503/docs
  EOT
}
