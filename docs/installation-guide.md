# Guía rápida de instalación

## 1. Crear cluster

Ver documentación:

[Creación/configuración del cluster con k3s](./02-k3s-cluster-setup.md)

Ejecutar:

```bash
    chmod +x bootstrap/k3s/00-initialize-k3s.sh
    ./bootstrap/k3s/00-initialize-k3s.sh
```

---

## 2. Instalar Cilium

Ver documentación:

[Instalación de Cilium](./03-install-cilium.md)

Ejecutar:

```bash
    chmod +x bootstrap/kind/01-install-cilium.sh
    ./bootstrap/scripts/01-install-cilium.sh
```

---

## 3. Instalar Argo CD

Ver documentación:

[Instalación de Argo CD](./04-install-argocd.md)

Ejecutar:

```bash
    chmod +x ./bootstrap/scripts/03-install-argocd.sh 
    ./bootstrap/scripts/03-install-argocd.sh
```

### 3.1 Configurar ArgoCD

Configurar acceso: 

- El primer paso recomendado es accerder a la UI de ArgoCD, ingresar con las credenciales presentadas por el resultado del script y cambiar la contraseña de administración (se pueden asignar roles y usuarios mas adelante).

Configurar repositorio (para este caso se utiliza la url HTTPS del repo de Gitlab, de igual manera puede cambiarse mas adelante):

- Crear un token personal y granular con los permisos para leer el repo, no se neceita de mas.
- Reemplazar las variables y ejecutar el siguiente comando en el cluster:


```bash
    kubectl create secret generic repo-gitops -n argocd --from-literal=type=git --from-literal=url=https://github.com/Mariozdz/vault-tec.git --from-literal=username=<username> --from-literal=password=<Token>

    kubectl label secret repo-gitops -n argocd argocd.argoproj.io/secret-type=repository
```

Una vez realizada la configuración de ArgoCD se puede continuar con el bootstrap de las applicaciones.

---

## 4. Aplicar recursos de kubernetes

Aplicar manualmente el Application de recursos del cluster, en este caso consiste de los namespace necesarios y las politicas de cilium (sin aplicar ninguna de momento), este apartado se puede escalar con otros componentes como definiciones de policies y RBAC de kubernetes.

```bash
    kubectl apply -f bootstrap/applications/root-cluster-baseline.yaml
```

Se recomienda añadir politicas de cilium una vez se termine de realizar el bootstrap de la plataforma, y se realiza al añadir los archivos YAML al kustomization correspondiente.

Validar:

```bash
    kubectl get namespaces
```

---

## 5. Crear PKI

Ver documentación:

[PKI y certificados](./08-pki.md)

En esta etapa se debe generar:

- Root CA offline
- Intermediate CA
- Certificado público de la CA
- Llave privada de la CA intermedia

---

## 6. Configurar la CA para cert manager

Este paso es obligatorio para realizar la instalación correcta de vault para este ejemplo con TLS activado.

Crear el Secret de la CA intermedia en el namespace `cert-manager`, la cual se encargará de generar los certificados de TLS para vault y mTLS para los clientes. Se recomienda utilizar cifrado de secretos en etcd y definición de reglas para su acceso.

```bash
    kubectl create secret tls intermediate-ca-secret -n cert-manager --cert=intermediate-ca.crt --key=intermediate-ca.key
```

---


## 5. Aplicar recursos para la plataforma de PKI

Aplicar el Argocd Application:

```bash
    kubectl apply -f bootstrap/applications/root-pki-platform.yaml
```

Validar:

```bash
    kubectl get clusterissuer
    kubectl get certificates -A
```


Una vez listos los componentes, se pueden añadir recursos necesarios, como la definición de certificados de cliente para aplicaciones dentro del server, en caso de que desee utilizar el app demo: curl-app, es ncesario añadir la definición de su certificado de cliente y el trust bundle del CA con el fin de facilitar el proceso.

---

## 6. Aplicar recursos para la plataforma de seguridad (Vault)

Aplicar el Application:

```bash
    kubectl apply -f bootstrap/applications/root-security-platform.yaml
```

Validar:

```bash
    kubectl get pods -n vault
    kubectl get svc -n vault
```


> Vault no se presentará como "Synced" en ArgoCD hasta que se realice el proceso de desellado completamente.
---

## 7. Inicializar y desellar Vault

Ver documentación:

[Bootstrap de Vault](./10-vault-bootstrap.md)

Guardar de forma segura:

- Unseal keys
- Root token

Validar:

```bash
    kubectl exec -n vault vault-0 -- vault status
```

Resultado esperado:

- `Initialized: true`
- `Sealed: false`

---

## 8. Aplicar políticas de Cilium (opcional)

Añadir los recursos de ejemplo de politicas al archivo infrastructure/cilium/policies/overlays/lab/kustomization.yaml:

resources:

    - argocd

    - vault

Resultado esperado:

- Políticas de red aplicadas
- Acceso a Vault restringido
- Solo clientes autorizados pueden comunicarse con Vault

---

## 9. Desplegar aplicación demo (opcional)

Aplicar el Application:

```bash
    kubectl apply -f bootstrap/applications/root-apps.yaml
```

Validar:

```bash
    kubectl get pods -n curl-app
```

---

## 10. Validación final

Ver documentación:

[Validación end-to-end](./13-validation.md)

Validaciones principales:

```bash
    kubectl get applications -n argocd
    kubectl get certificates -A
    kubectl get pods -A
    kubectl get ciliumnetworkpolicies -A
```

Validar Vault:

```bash
    kubectl exec -n curl-app <pod> -- curl https://vault.vault.svc.cluster.local:8200/v1/sys/health
```

Validar autenticación mTLS:

```bash
    kubectl exec -n curl-app <pod> -- curl --cert /certs/tls.crt --key /certs/tls.key https://vault.vault.svc.cluster.local:8200/v1/auth/cert/login
```

---
