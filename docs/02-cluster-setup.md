# Creación del cluster Kubernetes (Kind)

## Archivos relacionados

bootstrap/kind/00-cluster-initialization.sh

bootstrap/kind/config.yaml

## Descripción del script

El script realiza las siguientes acciones:

Elimina un cluster existente con el mismo nombre (si existe)
Crea un nuevo cluster utilizando un archivo de configuración
Verifica la conectividad del cluster
Muestra los nodos disponibles

## Script

```bash
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
```

## Ejecución

```bash
chmod +x bootstrap/kind/00-cluster-initialization.sh
./bootstrap/kind/00-cluster-initialization.sh
```

## Validación

```bash
kubectl get nodes
```

## Resultado esperado

Nodo(s) en estado Ready
Contexto activo: kind-secure-cluster

```bash
kubectl config current-context
```

## Consideraciones

El script elimina cualquier cluster previo con el mismo nombre
El archivo config.yaml define la configuración del cluster (red, nodos, etc.)
Este entorno es únicamente para desarrollo y validación

## Problemas comunes

Error: cluster already exists

Solución:

```bash
kind delete cluster --name secure-cluster
```

Error: Docker no disponible

Verificar:

```bash
docker ps
```

kubectl no apunta al cluster correcto

```bash
kubectl config use-context kind-secure-cluster
```

## Resultado esperado

Al finalizar:

Cluster Kind creado correctamente
kubectl configurado
Nodos disponibles
Listo para instalar Cilium y Argo CD

## Conclusión

Este paso establece la base sobre la cual se desplegará la arquitectura completa, permitiendo reproducibilidad y control del entorno desde el inicio.