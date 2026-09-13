# Políticas de red con Cilium

## Archivos relacionados

argocd/applications/< env >/cluster-baseline/08-cilium-policies.yaml  
infrastructure/cilium/policies/


## Descripción

Las políticas de red con Cilium permiten:

- Restringir el tráfico entre pods
- Permitir únicamente comunicaciones explícitas
- Aplicar segmentación basada en identidad
- Implementar un modelo Zero Trust dentro del cluster

En este sistema, las políticas se gestionan mediante Argo CD.

## Instalación

Las políticas se despliegan mediante Argo CD a través de un recurso Application.

El Application define:

- La ubicación de las políticas en el repositorio
- La estructura base y overlays por entorno
- La sincronización automática en el cluster


## Flujo

1. Las políticas son definidas en el repositorio  
2. Argo CD detecta los cambios  
3. Se aplican los manifiestos en el cluster  
4. Cilium evalúa y aplica las reglas de tráfico  


## Tipos de políticas utilizadas

### Política base

Define reglas generales del cluster, como:

- Permitir tráfico DNS
- Permitir acceso al API server
- Permitir comunicación interna controlada


### Políticas específicas

Definen accesos concretos entre componentes, por ejemplo:

- Permitir acceso de curl-app a Vault
- Restringir acceso desde otros namespaces
- Controlar tráfico saliente

## Uso en la arquitectura

Las políticas permiten:

- Restringir acceso a Vault únicamente a clientes autorizados
- Bloquear tráfico innecesario entre namespaces
- Controlar el flujo de red entre componentes críticos

## Validación

Verificar que las políticas están aplicadas:

```bash
kubectl get ciliumnetworkpolicies -A  
```


Verificar conectividad permitida:

```bash
kubectl exec -n curl-app <pod> -- curl https://vault.vault.svc.cluster.local:8200  
```


Verificar conectividad bloqueada:

```bash
kubectl run test --rm -it --image=curlimages/curl -n default -- sh  

curl https://vault.vault.svc.cluster.local:8200  

```


## Resultado esperado

- Las políticas están presentes en el cluster  
- curl-app puede acceder a Vault  
- Otros namespaces no pueden acceder  
- Tráfico restringido correctamente  


## Consideraciones

- Las políticas deben aplicarse después de desplegar los servicios  
- Un error en las políticas puede bloquear el tráfico completamente  
- Se recomienda iniciar con políticas permisivas y luego restringir  


## Problemas comunes

### Tráfico bloqueado inesperadamente

Verificar políticas aplicadas:

```bash
kubectl describe ciliumnetworkpolicy  
```


### DNS no funciona

Verificar reglas que permiten tráfico hacia CoreDNS  


### Aplicaciones no pueden comunicarse

Revisar labels y selectors en las políticas  

## Resultado final

Al finalizar:

- Políticas de red activas  
- Tráfico controlado entre componentes  
- Acceso restringido a servicios críticos  
- Modelo Zero Trust aplicado  
