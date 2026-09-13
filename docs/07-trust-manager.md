# Instalación de trust-manager


## Archivos relacionados

argocd/applications/< env >/pki-platform/03-trust-manager-install.yaml  
infrastructure/trust-manager/install/values/< env >.yaml  
infrastructure/trust-manager/bundles/base/<env>/kustomization.yaml

## Descripción

trust-manager es el componente encargado de:

- Distribuir certificados de confianza (CA)
- Generar ConfigMaps con bundles de certificados
- Permitir que las aplicaciones confíen en servicios internos
- Eliminar la necesidad de configurar certificados manualmente en cada pod


## Instalación

La instalación se realiza mediante Argo CD a través de un recurso Application.

El Application define:

- El chart oficial de trust-manager
- La versión a utilizar
- Los valores de configuración por entorno

Argo CD sincroniza el recurso y despliega trust-manager en el cluster.


## Flujo

1. El Application es definido en el repositorio
2. Argo CD detecta el cambio
3. Se descarga el chart de Helm
4. Se aplican los valores definidos
5. trust-manager se despliega en el namespace correspondiente


## Validación

Verificar estado de la aplicación:

```bash
kubectl -n argocd get applications  
```

Verificar pods:

```bash
kubectl get pods -n cert-manager  
```

Verificar CRDs:

```bash
kubectl get crds | grep trust  
```

## Resultado esperado

- Application en estado SYNCED / HEALTHY  
- Pods en estado Running  
- CRDs de trust-manager disponibles  


## Configuración de bundles

Una vez instalado trust-manager, se pueden definir bundles de certificados.

Un bundle permite:

- Leer una CA desde un Secret o ConfigMap
- Distribuirla automáticamente a múltiples namespaces
- Generar ConfigMaps con la CA en cada namespace destino


## Uso en la arquitectura

En este sistema, trust-manager se utiliza para:

- Distribuir la CA interna generada en la PKI
- Permitir que las aplicaciones confíen en Vault
- Simplificar la configuración de TLS en los clientes


## Consideraciones

- trust-manager depende de cert-manager
- Solo distribuye certificados públicos (no llaves privadas)
- No reemplaza la autenticación mTLS, solo gestiona la confianza
- Puede limitarse a namespaces específicos mediante namespaceSelector


## Problemas comunes

### Pods no inician

```bash
kubectl -n cert-manager logs <pod>  
```

### Bundle no se aplica

```bash
kubectl get bundles  

kubectl describe bundle <nombre>  
```

### ConfigMap no aparece en namespace

Verificar configuración de namespaceSelector  
Verificar labels del namespace  


## Siguiente paso

Definir la infraestructura de certificados (PKI) y distribuir la CA.

Ver:

- 08-pki.md  


## Resultado final

Al finalizar:

- trust-manager instalado mediante GitOps  
- Capacidad de distribuir CA en el cluster  
- Base establecida para la confianza entre componentes  
