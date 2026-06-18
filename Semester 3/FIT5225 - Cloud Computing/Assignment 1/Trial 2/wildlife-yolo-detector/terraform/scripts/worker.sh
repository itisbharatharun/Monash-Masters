#!/usr/bin/env bash
# =============================================================================
# worker.sh — Joins this node to the Kubernetes cluster as a worker.
# Runs AFTER common.sh and AFTER join_command.sh has been copied here.
# /tmp/join_command.sh is uploaded by Terraform's file provisioner.
# =============================================================================
set -euo pipefail

echo ">>> [worker] Joining Kubernetes cluster..."
sudo bash /tmp/join_command.sh

echo ">>> [worker] Node join complete."
