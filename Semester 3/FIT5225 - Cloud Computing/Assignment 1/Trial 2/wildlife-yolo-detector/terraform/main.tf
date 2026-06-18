# =============================================================================
# main.tf — CloudEco Infrastructure on Google Cloud Platform (GCP)
#
# Provisions end-to-end with a single `terraform apply`:
#   1. Firewall rules (SSH, K8s API, NodePort range, internal traffic)
#   2. Static external IPs for all 3 nodes
#   3. VM instances: k8s-master, k8s-worker1, k8s-worker2 (Melbourne)
#   4. K8s control plane bootstrap on master (containerd + kubeadm init + Flannel)
#   5. Fetch join command locally from master
#   6. K8s worker bootstrap + cluster join on both workers
#
# Variables are abstracted in variables.tf.
# Data sources dynamically resolve project, network, and OS image OCIDs
# so no IDs are hardcoded in this configuration.
# =============================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ---------------------------------------------------------------------------
# Data Sources
# Dynamically fetches project metadata, VPC network self_link, and the
# latest Ubuntu 22.04 LTS image — nothing is hardcoded.
# ---------------------------------------------------------------------------

data "google_project" "current" {
  project_id = var.project_id
}

data "google_compute_network" "default" {
  name    = "default"
  project = data.google_project.current.project_id
}

data "google_compute_image" "ubuntu_2204" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# ---------------------------------------------------------------------------
# Firewall Rules
# Prefixed "cloudeco-mel-" to avoid name conflicts with any pre-existing
# rules in the same GCP project (firewall rules are project-global).
# All rules target only VMs tagged "cloudeco-k8s".
# ---------------------------------------------------------------------------

resource "google_compute_firewall" "cloudeco_mel_allow_ssh" {
  name    = "cloudeco-mel-allow-ssh"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cloudeco-k8s"]
}

resource "google_compute_firewall" "cloudeco_mel_allow_k8s_api" {
  name    = "cloudeco-mel-allow-k8s-api"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cloudeco-k8s"]
}

resource "google_compute_firewall" "cloudeco_mel_allow_app" {
  name    = "cloudeco-mel-allow-app"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cloudeco-k8s"]
}

resource "google_compute_firewall" "cloudeco_mel_allow_internal" {
  name    = "cloudeco-mel-allow-internal"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "all"
  }

  # GCP default VPC internal IP range
  source_ranges = ["10.128.0.0/9"]
  target_tags   = ["cloudeco-k8s"]
}

# ---------------------------------------------------------------------------
# Static External IP Addresses
# Reserved before VM creation so IPs are stable across reboots/reprovisioning.
# ---------------------------------------------------------------------------

resource "google_compute_address" "master_ip" {
  name   = "cloudeco-master-ip"
  region = var.region
}

resource "google_compute_address" "worker1_ip" {
  name   = "cloudeco-worker1-ip"
  region = var.region
}

resource "google_compute_address" "worker2_ip" {
  name   = "cloudeco-worker2-ip"
  region = var.region
}

# ---------------------------------------------------------------------------
# VM Instances
# All three nodes use the same machine type and OS image.
# OS image is resolved dynamically via the data source above.
# ---------------------------------------------------------------------------

resource "google_compute_instance" "k8s_master" {
  name         = "k8s-master"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["cloudeco-k8s"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_2204.self_link
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    access_config {
      nat_ip = google_compute_address.master_ip.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "google_compute_instance" "k8s_worker1" {
  name         = "k8s-worker1"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["cloudeco-k8s"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_2204.self_link
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    access_config {
      nat_ip = google_compute_address.worker1_ip.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "google_compute_instance" "k8s_worker2" {
  name         = "k8s-worker2"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["cloudeco-k8s"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_2204.self_link
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    access_config {
      nat_ip = google_compute_address.worker2_ip.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# ---------------------------------------------------------------------------
# Step 1: Bootstrap the Kubernetes control plane on the master node.
#
# Runs common.sh (containerd + kubeadm install) then master.sh
# (kubeadm init + Flannel CNI + save join command to /tmp/join_command.sh).
#
# depends_on the master VM so Terraform waits for the VM to exist before
# attempting SSH. The connection block retries SSH until the VM is ready.
# ---------------------------------------------------------------------------

resource "null_resource" "k8s_master_bootstrap" {
  depends_on = [
    google_compute_instance.k8s_master,
    google_compute_firewall.cloudeco_mel_allow_ssh,
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = google_compute_address.master_ip.address
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/common.sh",
      "${path.module}/scripts/master.sh",
    ]
  }
}

# ---------------------------------------------------------------------------
# Step 2: Fetch the join command from the master to the local machine.
#
# local-exec SSHes to master and saves /tmp/join_command.sh locally as
# /tmp/cloudeco_join_command.sh. This file is then uploaded to each worker
# in Step 3 using a file provisioner.
#
# depends_on master bootstrap completing (implicit via null_resource reference).
# ---------------------------------------------------------------------------

resource "null_resource" "fetch_join_command" {
  depends_on = [null_resource.k8s_master_bootstrap]

  provisioner "local-exec" {
    command = <<-EOT
      ssh -i ${pathexpand(var.ssh_private_key_path)} \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          ubuntu@${google_compute_address.master_ip.address} \
          'cat /tmp/join_command.sh' \
          > /tmp/cloudeco_join_command.sh
      echo "Join command saved to /tmp/cloudeco_join_command.sh"
      cat /tmp/cloudeco_join_command.sh
    EOT
  }
}

# ---------------------------------------------------------------------------
# Step 3a: Bootstrap worker 1 and join it to the cluster.
#
# Sequencing:
#   a) common.sh installs containerd + K8s binaries on worker1
#   b) file provisioner uploads the join command from local /tmp/
#   c) worker.sh executes the join command with sudo
#
# depends_on both fetch_join_command (join cmd must exist locally) and
# the worker1 VM (must exist before SSH).
# ---------------------------------------------------------------------------

resource "null_resource" "k8s_worker1_bootstrap" {
  depends_on = [
    null_resource.fetch_join_command,
    google_compute_instance.k8s_worker1,
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = google_compute_address.worker1_ip.address
    timeout     = "10m"
  }

  # Install containerd and K8s binaries
  provisioner "remote-exec" {
    scripts = ["${path.module}/scripts/common.sh"]
  }

  # Upload the join command that was fetched from master in Step 2
  provisioner "file" {
    source      = "/tmp/cloudeco_join_command.sh"
    destination = "/tmp/join_command.sh"
  }

  # Join the cluster
  provisioner "remote-exec" {
    scripts = ["${path.module}/scripts/worker.sh"]
  }
}

# ---------------------------------------------------------------------------
# Step 3b: Bootstrap worker 2 and join it to the cluster.
# Identical to 3a but targets worker2. Runs in parallel with 3a since
# both only depend on fetch_join_command, not on each other.
# ---------------------------------------------------------------------------

resource "null_resource" "k8s_worker2_bootstrap" {
  depends_on = [
    null_resource.fetch_join_command,
    google_compute_instance.k8s_worker2,
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = google_compute_address.worker2_ip.address
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    scripts = ["${path.module}/scripts/common.sh"]
  }

  provisioner "file" {
    source      = "/tmp/cloudeco_join_command.sh"
    destination = "/tmp/join_command.sh"
  }

  provisioner "remote-exec" {
    scripts = ["${path.module}/scripts/worker.sh"]
  }
}
