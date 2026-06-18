# =============================================================================
# main.tf — CloudEco Infrastructure on Google Cloud Platform (GCP)
# Provisions: Firewall rules, Static IPs, and 3 VM instances (1 master + 2 workers)
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
# Data Sources — dynamically fetch existing GCP resources rather than
# hardcoding IDs. This mirrors the IaC best practice of using data sources
# to decouple configuration from environment-specific identifiers.
# ---------------------------------------------------------------------------

# Dynamically resolve the active GCP project metadata (equivalent to
# fetching OCIDs in OCI Terraform — avoids hardcoding project numbers).
data "google_project" "current" {
  project_id = var.project_id
}

# Dynamically look up the default VPC network by name so firewall rules
# and VM interfaces reference the live network resource, not a string literal.
data "google_compute_network" "default" {
  name    = "default"
  project = data.google_project.current.project_id
}

# Dynamically resolve the Ubuntu 22.04 LTS image so the exact image version
# is never hardcoded — Terraform always fetches the latest available image.
data "google_compute_image" "ubuntu_2204" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# ---------------------------------------------------------------------------
# Firewall Rules — all reference the dynamically resolved network self_link
# ---------------------------------------------------------------------------

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-node"]
}

resource "google_compute_firewall" "allow_k8s_api" {
  name    = "allow-k8s-api"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-node"]
}

resource "google_compute_firewall" "allow_app" {
  name    = "allow-app"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-node"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.128.0.0/9"]
  target_tags   = ["k8s-node"]
}

# ---------------------------------------------------------------------------
# Static External IP Addresses
# ---------------------------------------------------------------------------

resource "google_compute_address" "master_ip" {
  name   = "k8s-master-ip"
  region = var.region
}

resource "google_compute_address" "worker1_ip" {
  name   = "k8s-worker1-ip"
  region = var.region
}

resource "google_compute_address" "worker2_ip" {
  name   = "k8s-worker2-ip"
  region = var.region
}

# ---------------------------------------------------------------------------
# VM Instances — boot disk image resolved dynamically via data source
# ---------------------------------------------------------------------------

resource "google_compute_instance" "k8s_master" {
  name         = "k8s-master"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["k8s-node"]

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

  tags = ["k8s-node"]

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

  tags = ["k8s-node"]

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
