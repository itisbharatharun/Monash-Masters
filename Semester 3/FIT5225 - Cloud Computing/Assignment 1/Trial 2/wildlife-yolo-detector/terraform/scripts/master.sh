#!/usr/bin/env bash
# =============================================================================
# master.sh — Bootstraps the Kubernetes control plane on the master node.
# Runs AFTER common.sh on the master only.
# =============================================================================
set -euo pipefail

echo ">>> [master] Fetching internal and external IPs from GCP metadata..."
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

echo "    Internal IP: $INTERNAL_IP"
echo "    External IP: $EXTERNAL_IP"

echo ">>> [master] Running kubeadm init..."
sudo kubeadm init \
  --apiserver-advertise-address="$INTERNAL_IP" \
  --apiserver-cert-extra-sans="$EXTERNAL_IP" \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///var/run/containerd/containerd.sock \
  --ignore-preflight-errors=NumCPU

echo ">>> [master] Configuring kubeconfig for ubuntu user..."
mkdir -p /home/ubuntu/.kube
sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
chmod 600 /home/ubuntu/.kube/config

export KUBECONFIG=/home/ubuntu/.kube/config

echo ">>> [master] Installing Flannel CNI..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo ">>> [master] Waiting for control plane pods to be ready (up to 3 minutes)..."
kubectl wait --for=condition=Ready pod \
  --selector=tier=control-plane \
  --namespace=kube-system \
  --timeout=180s || true

echo ">>> [master] Generating join command for worker nodes..."
kubeadm token create --print-join-command | tee /tmp/join_command.sh
chmod 644 /tmp/join_command.sh

echo ">>> [master] K8s control plane bootstrap complete."
echo "    Join command saved to /tmp/join_command.sh"
