# Instalación de Cilium

## Archivos relacionados

bootstrap/scripts/01-install-cilium.sh

## Descripción

El script realiza las siguientes acciones:

1. Agrega el repositorio de Helm de Cilium
2. Instala o actualiza Cilium en el cluster
3. Configura parámetros clave de red
4. Habilita componentes de observabilidad (Hubble)
5. Espera a que los componentes estén listos
6. Verifica el estado del cluster

## Script

```bash
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
```


## Ejecución

chmod +x scripts/install-cilium.sh  
./scripts/install-cilium.sh  

## Validación

```bash
kubectl -n kube-system get pods -l k8s-app=cilium  

kubectl get nodes  
```

## Resultado esperado

- Pods de Cilium en estado Running  
- Nodo(s) en estado Ready  
- Conectividad de red funcional  


## Consideraciones

- Cilium reemplaza el kube-proxy mediante kubeProxyReplacement=true  
- Se habilita Hubble para observabilidad de red  
- El cluster debe haber sido creado previamente con soporte para Cilium  
- El nombre del nodo de control debe coincidir con el configurado en Kind  



## Problemas comunes

### Cilium no inicia correctamente

```bash
kubectl -n kube-system logs -l k8s-app=cilium  
```

### Problemas de conectividad

```bash
kubectl get nodes  

cilium status  
```

### Error en conexión al API server

Verificar el valor de k8sServiceHost:

```bash
${CLUSTER_NAME}-control-plane  
```


## Resultado final

Al finalizar:

- Cilium instalado como CNI  
- Red del cluster operativa  
- Observabilidad habilitada (Hubble)  
- Cluster listo para continuar con la instalación de Argo CD  
