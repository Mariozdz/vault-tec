# Overview de la Arquitectura

## Descripción general

La arquitectura implementa un modelo de gestión de secretos seguro y automatizado en Kubernetes, basado en:

- GitOps como mecanismo de control
- Zero Trust como principio de seguridad
- mTLS como mecanismo de autenticación
- Distribución declarativa de confianza

El sistema evita el uso de secretos estáticos y centraliza la gestión mediante HashiCorp Vault.

## Componentes principales

### Kubernetes

Plataforma base donde se ejecutan todos los componentes.


### Cilium

- Provee conectividad de red
- Implementa políticas de red (CiliumNetworkPolicy)
- Permite segmentación basada en identidad


### Argo CD

- Implementa el modelo GitOps
- Sincroniza el estado del cluster desde el repositorio Git
- Gestiona aplicaciones y componentes de infraestructura


### cert-manager

- Emite certificados X.509 dentro del cluster
- Gestiona la PKI interna
- Automatiza la renovación de certificados


### trust-manager

- Distribuye las anclas de confianza (CA)
- Permite a los pods confiar en servicios internos
- Elimina la necesidad de configurar manualmente certificados en cada aplicación


### Vault

- Gestiona secretos de forma centralizada
- Implementa autenticación basada en certificados (mTLS)
- Aplica políticas de acceso


### Cilium Network Policies

- Restringen el tráfico entre componentes
- Implementan un modelo Zero Trust
- Permiten solo comunicaciones explícitamente definidas


## Flujo de funcionamiento

1. El cluster es creado con Kind
2. Cilium se instala como CNI
3. Argo CD se instala y se inicializa el modelo GitOps
4. cert-manager emite certificados internos
5. trust-manager distribuye la CA
6. Vault se despliega con TLS habilitado
7. Se configuran políticas y autenticación en Vault
8. Cilium aplica políticas de red


## Principios de diseño

### GitOps

- Git como única fuente de verdad
- Cambios controlados mediante commits
- Reconciliación automática


### Zero Trust

- No se confía en ningún componente por defecto
- Todo acceso debe estar explícitamente permitido
- Segmentación estricta de red


### Seguridad basada en identidad

- Autenticación mediante certificados
- Eliminación de credenciales estáticas
- Control de acceso mediante políticas

### Automatización

- Emisión de certificados automatizada
- Distribución de confianza automatizada
- Configuración declarativa


## Resultado esperado

Al finalizar la implementación:

- Todos los componentes están gestionados por GitOps
- La comunicación es segura mediante TLS
- Los clientes se autentican mediante mTLS
- El acceso a secretos está controlado por políticas
- La red está segmentada mediante Zero Trust
