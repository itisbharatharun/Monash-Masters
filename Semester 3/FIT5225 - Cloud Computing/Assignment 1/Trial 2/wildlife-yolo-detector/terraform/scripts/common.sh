#!/usr/bin/env bash
# =============================================================================
# common.sh — Node pre-requisites: containerd + kubeadm + kubelet + kubectl
# Runs on ALL three nodes (master and both workers) before any K8s bootstrap.
# =============================================================================
set -euo pipefail

echo ">>> [common] Cleaning up any stale apt sources from previous runs..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo rm -f /etc/apt/keyrings/docker.gpg

echo ">>> [common] Waiting for cloud-init to finish..."
sudo cloud-init status --wait || true

echo ">>> [common] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo ">>> [common] Loading kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo ">>> [common] Applying sysctl params..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo ">>> [common] Installing containerd..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q
sudo apt-get install -yq apt-transport-https ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -q
sudo apt-get install -yq containerd.io

echo ">>> [common] Configuring containerd with SystemdCgroup=true..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

echo ">>> [common] Installing kubeadm, kubelet, kubectl (v1.29)..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt-get update -q
sudo apt-get install -yq kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet

echo ">>> [common] Node pre-requisites complete."
