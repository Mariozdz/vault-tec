# Instalación de Argo CD

## Archivos relacionados

bootstrap/scripts/04-install-argocd.sh

## Descripción

El script realiza las siguientes acciones:

1. Verifica que el cluster esté disponible
2. Valida que CoreDNS esté funcionando correctamente
3. Crea el namespace de Argo CD
4. Instala Argo CD utilizando los manifiestos oficiales
5. Espera a que los componentes principales estén listos
6. Obtiene la contraseña inicial de acceso
7. Muestra instrucciones para acceder a la interfaz

## Script

```bash
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
echo "Credenciales Argo CD"  
echo "URL: https://localhost:8080"  
echo "Usuario: admin"  
echo "Password: $ARGOCD_PASSWORD"  
echo "======================================"  

echo "Para acceder ejecuta:"  
echo "kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443"  
```

## Ejecución

```bash
chmod +x scripts/install-argocd.sh  
./scripts/install-argocd.sh  
```

## Acceso a Argo CD

Ejecutar:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443  
```

Luego abrir en el navegador:

https://localhost:8080  

Credenciales:

- Usuario: admin  
- Password: obtenido del script  

Una vez se tiene acceso, se recomienda el cambio de contraseña o la creación de las cuentas correspondientes para los administradores.

## Validación

```bash
kubectl -n argocd get pods  

kubectl -n argocd get svc  
```


## Resultado esperado

- Todos los pods en estado Running  
- Servicios disponibles en el namespace argocd  
- Acceso exitoso a la interfaz web  

## Consideraciones

- Argo CD se instala utilizando los manifiestos oficiales  
- Se utiliza server-side apply para evitar conflictos  
- El acceso inicial se realiza mediante port-forward  
- La contraseña inicial se obtiene desde un Secret  


## Problemas comunes

### Argo CD no inicia

```bash
kubectl -n argocd logs deployment/argocd-server  
```

### Error al obtener la contraseña

```bash
kubectl -n argocd get secret argocd-initial-admin-secret  
```

### No se puede acceder a la UI

Verificar que el port-forward esté activo:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443  
```

## Resultado final

Al finalizar:

- Argo CD instalado en el cluster  
- Acceso disponible a la interfaz web  
- Cluster listo para implementar GitOps  
