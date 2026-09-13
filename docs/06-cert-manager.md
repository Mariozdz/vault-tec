# Instalación de cert-manager

## Archivos relacionados

argocd/applications/< env >/pki-platform/02-cert-manager-install.yaml  
infrastructure/cert-manager/install/values/< env >.yaml  

## Descripción

cert-manager es el componente encargado de:

- Emitir certificados X.509 dentro del cluster
- Gestionar la PKI interna
- Automatizar la renovación de certificados

En este paso, cert-manager se instala como una Application de Argo CD, lo que permite su gestión declarativa desde el repositorio.

## Instalación

La instalación se realiza automáticamente mediante Argo CD.

El recurso Application define:

- El chart de Helm oficial de cert-manager
- La versión a utilizar
- Los valores de configuración por entorno

Argo CD sincroniza este recurso y despliega cert-manager en el cluster.

## Validación

Verificar que la aplicación esté sincronizada:

```bash
kubectl -n argocd get applications  
```

Verificar pods:

```bash
kubectl get pods -n cert-manager  
```

Verificar CRDs:

```bash
kubectl get crds | grep cert-manager  
```

## Resultado esperado

- Application en estado SYNCED / HEALTHY  
- Pods en estado Running  
- CRDs instalados correctamente  


## Consideraciones

- cert-manager se instala antes de configurar cualquier CA  
- No se requiere una CA en esta etapa  
- Este paso únicamente instala el controlador  


## Problemas comunes

### Application no sincroniza

```bash
kubectl -n argocd describe application cert-manager-install-lab  
```

### Pods no inician

```bash
kubectl -n cert-manager logs <pod>  
```

### CRDs no disponibles

```bash
kubectl get crds | grep cert-manager  
```

## Siguiente paso

Configurar la autoridad certificadora (CA) y el ClusterIssuer.

Ver:

- 07-pki.md  
- 08-cert-manager-config.md  

## Resultado final

Al finalizar:

- cert-manager desplegado mediante GitOps  
- Controlador listo para emitir certificados  
- Cluster preparado para configurar PKI  
