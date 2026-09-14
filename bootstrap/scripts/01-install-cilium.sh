#!/usr/bin/env bash
set -euo pipefail

CILIUM_VERSION="1.19.1"

echo "Detectando Kubernetes API Server..."

K8S_API_HOST="${K8S_API_HOST:-$(kubectl get endpoints kubernetes \
  -o jsonpath='{.subsets[0].addresses[0].ip}')}"

K8S_API_PORT="${K8S_API_PORT:-$(kubectl get endpoints kubernetes \
  -o jsonpath='{.subsets[0].ports[0].port}')}"

if [[ -z "$K8S_API_HOST" || -z "$K8S_API_PORT" ]]; then
  echo "No fue posible detectar el Kubernetes API Server."
  exit 1
fi

echo "API Server detectado:"
echo "  Host: $K8S_API_HOST"
echo "  Port: $K8S_API_PORT"

echo "Agregando repo de Helm de Cilium..."
helm repo add cilium https://helm.cilium.io/ || true
helm repo update

echo "Instalando Cilium..."

helm upgrade --install cilium cilium/cilium \
  --version "$CILIUM_VERSION" \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost="$K8S_API_HOST" \
  --set k8sServicePort="$K8S_API_PORT" \
  --set ipam.mode=kubernetes \
  --set operator.replicas=1 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

echo "Esperando que Cilium quede listo..."

kubectl rollout status ds/cilium \
  -n kube-system \
  --timeout=300s

kubectl rollout status deploy/cilium-operator \
  -n kube-system \
  --timeout=300s

kubectl rollout status deploy/coredns \
  -n kube-system \
  --timeout=300s

echo "Estado final:"
kubectl get pods -A
kubectl get nodes -o wide

echo "Cluster K3s listo con Cilium."