# GitOps Secure Secrets Management Lab

Este repositorio contiene la implementación GitOps para desplegar una arquitectura segura de gestión de secretos en Kubernetes usando Argo CD, Cilium, cert-manager, trust-manager y HashiCorp Vault.


## 🚀 Guía rápida de instalación

Para desplegar la arquitectura completa paso a paso:

- [Guía de instalación completa](docs/installation-guide.md)

Esta guía describe el flujo completo desde la creación del cluster hasta la validación final del sistema.

---

## Arquitectura general

Componentes principales:

- Kubernetes
- Cilium
- Argo CD
- cert-manager
- trust-manager
- HashiCorp Vault
- CiliumNetworkPolicies

---

## Índice de implementación

### 1. Contexto y diseño

- [Overview de la arquitectura](docs/00-overview.md)
- [Prerrequisitos](docs/01-prerequisites.md)

### 2. Preparación del cluster

- [Creación/configuración del cluster](docs/02-cluster-setup.md)
- [Instalación de Cilium](docs/03-install-cilium.md)
- [Instalación de Argo CD](docs/04-install-argocd.md)

### 3. Bootstrap GitOps

- [Bootstrap del root application](docs/05-bootstrap-root-app.md)

### 4. Infraestructura de seguridad

- [cert-manager](docs/06-cert-manager.md)
- [trust-manager](docs/07-trust-manager.md)
- [PKI y certificados](docs/08-pki.md)

### 5. Vault

- [Instalación de Vault](docs/09-vault.md)
- [Bootstrap de Vault](docs/10-vault-bootstrap.md)
- [Definición de identidades y políticas de Vault](docs/16-vault-identities-policies.md)
- [Flujo de autenticación Vault con cert auth](docs/17-vault-cert-auth-flow.md)
- [Propuesta de definición de roles para administración](docs/21-vault-roles.md)

### 6. Conectividad Zero Trust entre clústeres

- [Opción A - Nebula](docs/19-nebula-connectivity.md)
- [Opción B - OpenZiti](docs/20-openziti-connectivity.md)

### 6. Zero Trust networking interno

- [Cilium Network Policies](docs/11-cilium-policies.md)

### 7. Aplicación demo

- [curl-app y consumo de Vault](docs/12-demo-app.md)

### 8. Validación y operación

- [Validación end-to-end](docs/13-validation.md)
- [Troubleshooting](docs/14-troubleshooting.md)
- [Operación y mantenimiento](docs/15-operations.md)

---

## Orden general de despliegue

→ Cilium  
→ Argo CD  
→ Namespaces  
→ cert-manager  
→ trust-manager  
→ PKI resources  
→ Trust bundles  
→ Vault  
→ Vault resources  
→ Cilium policies  
→ Demo apps  
→ Validación  