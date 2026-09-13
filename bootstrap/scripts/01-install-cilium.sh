#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="secure-cluster"
CILIUM_VERSION="1.19.1"

echo "Agregando repo de Helm de Cilium..."
helm repo add cilium https://helm.cilium.io/ || true
helm repo update

echo "Instalando Cilium..."
helm upgrade --install cilium cilium/cilium \
  --version "$CILIUM_VERSION" \
  --namespace kube-system \
  --reuse-values \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost="${CLUSTER_NAME}-control-plane" \
  --set k8sServicePort=6443 \
  --set ipam.mode=kubernetes \
  --set nodeinit.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

echo "Esperando que Cilium quede listo..."
kubectl rollout status ds/cilium -n kube-system --timeout=300s || true
kubectl rollout status deploy/cilium-operator -n kube-system --timeout=300s || true
kubectl rollout status deploy/coredns -n kube-system --timeout=300s || true

echo "Estado final:"
kubectl get pods -A
kubectl get nodes -o wide

echo "Cluster '$CLUSTER_NAME' listo con Cilium."