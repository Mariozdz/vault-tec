#!/bin/bash

set -e

echo "Installing K3s..."

curl -sfL https://get.k3s.io | sh -s - server \
  --flannel-backend=none \
  --disable-network-policy \
  --disable-kube-proxy \
  --disable traefik \
  --disable servicelb

echo "Configuring kubeconfig..."

mkdir -p "$HOME/.kube"

sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$USER:$USER" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"

echo "K3s installation completed."

kubectl get nodes