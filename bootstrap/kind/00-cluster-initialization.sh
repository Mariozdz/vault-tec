#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="secure-cluster"
CONFIG_FILE="config.yaml"

echo "Eliminando cluster anterior si existe..."
kind delete cluster --name "$CLUSTER_NAME" || true

echo "Creando cluster nuevo con config: $CONFIG_FILE"
kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

echo "Verificando cluster..."
kubectl cluster-info --context "kind-$CLUSTER_NAME"
kubectl get nodes -o wide

echo "Cluster listo: $CLUSTER_NAME"