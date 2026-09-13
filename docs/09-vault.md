# Instalación de Vault

## Archivos relacionados

argocd/applications/< env >/security-platform/06-vault-install.yaml  
infrastructure/vault/install/values/< env >.yaml  

## Descripción

Vault es el componente encargado de:

- Gestionar secretos de forma centralizada
- Proveer acceso controlado mediante políticas
- Implementar autenticación basada en identidad (mTLS)
- Evitar el uso de credenciales estáticas

En este paso se realiza únicamente la instalación de Vault, sin configurarlo aún.


## Instalación

La instalación se realiza mediante Argo CD a través de un recurso Application.

El Application define:

- El chart oficial de Vault
- La versión a utilizar
- Los valores de configuración por entorno

Argo CD sincroniza el recurso y despliega Vault en el cluster.


## Flujo

1. El Application es definido en el repositorio  
2. Argo CD detecta el cambio  
3. Se descarga el chart de Helm  
4. Se aplican los valores definidos  
5. Vault se despliega en el namespace correspondiente  



## Validación

Verificar estado de la aplicación:

```bash
kubectl -n argocd get applications  
```

Verificar pods:

```bash
kubectl get pods -n vault  
```

Verificar servicio:

```bash
kubectl get svc -n vault  
```

## Resultado esperado

- Application en estado SYNCED / HEALTHY  
- Pods de Vault en estado Running  
- Servicio disponible dentro del cluster  

## Consideraciones

- Vault se despliega con TLS habilitado  
- El certificado es emitido por cert-manager  
- La configuración de almacenamiento depende del entorno (standalone o HA)  
- Vault aún no está inicializado ni configurado  



## Problemas comunes

### Pods no inician

```bash
kubectl -n vault logs <pod>  
```


### Problemas con TLS

```bash
kubectl describe certificate -n vault  
```


### Servicio no responde

```bash
kubectl get svc -n vault  
```

## Siguiente paso

Inicializar y configurar Vault.

Ver:

- 10-vault-bootstrap.md  

---

## Resultado final

Al finalizar:

- Vault desplegado mediante GitOps  
- Servicio disponible en el cluster  
- Listo para inicialización y configuración  
