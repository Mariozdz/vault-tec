# Creación del cluster Kubernetes (K3s)

## Archivos relacionados

`bootstrap/k3s/00-cluster-initialization.sh`

## Descripción del script

El script realiza las siguientes acciones:

* Instala K3s en modo servidor
* Deshabilita Flannel para permitir la instalación posterior de Cilium
* Deshabilita el controlador de NetworkPolicy incluido por defecto
* Deshabilita Traefik
* Deshabilita ServiceLB
* Configura el archivo `kubeconfig` para el usuario actual
* Ajusta los permisos del archivo de configuración
* Verifica el acceso al cluster mediante `kubectl`

## Script

```bash
#!/usr/bin/env bash

set -euo pipefail

echo "Instalando K3s..."

curl -sfL https://get.k3s.io | sh -s - server \
  --flannel-backend=none \
  --disable-network-policy \
  --disable traefik \
  --disable servicelb

echo "Configurando kubeconfig..."

mkdir -p "$HOME/.kube"

sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$USER:$USER" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"

echo "Verificando cluster..."

kubectl get nodes -o wide

echo "Cluster K3s instalado correctamente."
```

## Ejecución

Dar permisos de ejecución al script:

```bash
chmod +x bootstrap/k3s/00-cluster-initialization.sh
```

Ejecutar:

```bash
./bootstrap/k3s/00-cluster-initialization.sh
```

## Validación

Verificar que `kubectl` tenga acceso al cluster:

```bash
kubectl get nodes
```

También puede verificarse el estado del servicio K3s:

```bash
sudo systemctl status k3s
```

Y consultar la información del cluster:

```bash
kubectl cluster-info
```

## Resultado esperado

Después de la instalación:

* K3s se encuentra ejecutándose como servicio
* `kubectl` utiliza el cluster recién creado
* El nodo Kubernetes se encuentra disponible
* Flannel no se encuentra instalado
* Traefik y ServiceLB permanecen deshabilitados
* El cluster queda preparado para instalar Cilium y Argo CD

Antes de instalar Cilium, el nodo puede aparecer temporalmente en estado:

```text
NotReady
```
