# Infraestructura de Certificados (PKI)

## Descripción

El sistema (a nivel LAB/DEV) utiliza una PKI interna para:

- Habilitar TLS en servicios (Vault)
- Permitir autenticación mTLS entre componentes
- Establecer confianza entre aplicaciones

La PKI se compone de:

- Root CA (offline)
- Intermediate CA (utilizada dentro del cluster)
- Certificados emitidos para servicios y clientes


## Estructura de la PKI

- Root CA  
  - Generada fuera del cluster  
  - No se expone ni se almacena en Git  

- Intermediate CA  
  - Firmada por la Root CA  
  - Utilizada por cert-manager  
  - Se almacena como Secret en Kubernetes  

- Certificados finales  
  - Emitidos por cert-manager  
  - Utilizados por Vault y aplicaciones  


## Creación de la Root CA (offline)

Generar clave privada:
```bash

openssl genrsa -out root-ca.key 4096  

Generar certificado raíz:

openssl req -x509 -new -nodes \
  -key root-ca.key \
  -sha256 -days 3650 \
  -out root-ca.crt \
  -subj "/C=CR/O=Proyecto GitOps/CN=Root CA"

```

## Creación de la CA intermedia

Generar clave:

```bash
openssl genrsa -out intermediate-ca.key 4096  
```
Generar CSR:
```bash
openssl req -new \
  -key intermediate-ca.key \
  -out intermediate-ca.csr \
  -subj "/C=CR/O=Proyecto GitOps/CN=Intermediate CA"
```

Firmar con Root CA:

```bash
openssl x509 -req \
  -in intermediate-ca.csr \
  -CA root-ca.crt \
  -CAkey root-ca.key \
  -CAcreateserial \
  -out intermediate-ca.crt \
  -days 1825 \
  -sha256 
```

## Integración con Kubernetes

La CA intermedia se carga en el cluster como Secret con el nombre intermediate-ca-secret.

El Secret debe contener:

- tls.crt → certificado de la CA intermedia  
- tls.key → clave privada de la CA intermedia  

Este Secret será utilizado posteriormente por cert-manager
para emitir certificados.

## Relación con cert-manager

cert-manager utiliza la CA intermedia mediante un ClusterIssuer.

Flujo:

1. Se crea el Secret con la CA intermedia  
2. Se define un ClusterIssuer  
3. cert-manager emite certificados automáticamente  


## Relación con trust-manager

trust-manager utiliza la CA pública para:

- Distribuir confianza a los namespaces  
- Generar ConfigMaps con la CA  
- Permitir que los pods confíen en servicios internos  

## Consideraciones de seguridad

- La Root CA debe mantenerse fuera del cluster  
- No almacenar llaves privadas en el repositorio  
- Solo certificados públicos pueden versionarse  
- La CA intermedia debe protegerse adecuadamente  
- El acceso a la CA debe ser restringido  


## Resultado esperado

Al finalizar:

- Root CA generada offline  
- Intermediate CA disponible  
- Secret listo para ser usado por cert-manager  
- Base establecida para emisión de certificados  

