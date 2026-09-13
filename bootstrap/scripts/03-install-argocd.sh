#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="argocd"

echo "Verificando que el cluster responda..."
kubectl get nodes

echo "Verificando que CoreDNS esté listo..."
kubectl rollout status deployment/coredns -n kube-system --timeout=300s

echo "Creando namespace de Argo CD..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Instalando Argo CD..."
kubectl apply -n "$NAMESPACE" \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Esperando despliegues principales..."
kubectl rollout status deployment/argocd-server -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment/argocd-repo-server -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment/argocd-applicationset-controller -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment/argocd-notifications-controller -n "$NAMESPACE" --timeout=300s
kubectl rollout status statefulset/argocd-application-controller -n "$NAMESPACE" --timeout=300s

echo "Obteniendo contraseña inicial..."

ARGOCD_PASSWORD=$(kubectl -n "$NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "======================================"
echo "🔐 Credenciales Argo CD"
echo "URL: https://localhost:8080"
echo "Usuario: admin"
echo "Password: $ARGOCD_PASSWORD"
echo "======================================"

echo "Para acceder ejecuta:"
echo "kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443"