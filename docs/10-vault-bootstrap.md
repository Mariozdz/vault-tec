# Bootstrap de Vault


## Descripción

El proceso de bootstrap incluye:

- Inicialización de Vault
- Desellado (unseal)
- Habilitación de motores de secretos
- Configuración de autenticación
- Creación de políticas

Este proceso se realiza después de que Vault ha sido desplegado.

## Inicialización

Vault debe ser inicializado manualmente.

Esto genera:

- Unseal keys
- Root token

Ejecutar:

```bash

export VAULT_ADDR="https://vault.vault.svc.cluster.local:8200"
export VAULT_CACERT="/vault/ssl/ca.crt"
export VAULT_TOKEN="<INITIAL_ROOT_TOKEN>"

kubectl exec -n vault -it vault-0 -- sh
vault operator init
```

El comando generará una salida similar a:

```bash
Unseal Key 1: <valor-sensible>
Unseal Key 2: <valor-sensible>
Unseal Key 3: <valor-sensible>
Unseal Key 4: <valor-sensible>
Unseal Key 5: <valor-sensible>

Initial Root Token: <valor-sensible>
```


## Desellado de Vault

Después de la inicialización, Vault queda sellado.

Para desbloquearlo, se deben aplicar las unseal keys requeridas por el umbral definido durante la inicialización.

Por defecto, Vault suele generar 5 claves y requerir 3 para el desellado.

Ejecutar el comando usando cada clave requerida:

```bash
vault operator unseal <UNSEAL_KEY_1>
```

```bash
vault operator unseal <UNSEAL_KEY_2>
```

```bash
vault operator unseal <UNSEAL_KEY_3>
```

Validar el estado:

```bash
vault status
```

Resultado esperado:

```bash
Initialized    true
Sealed         false
```


## Autenticación administrativa temporal

Para realizar la configuración inicial, se puede usar temporalmente el root token generado durante la inicialización.

Ingresar al pod de Vault:

```bash
kubectl exec -it -n vault vault-0 -- sh
```

Dentro del pod, exportar las variables necesarias:

```bash
export VAULT_ADDR="https://vault.vault.svc.cluster.local:8200"
export VAULT_CACERT="/vault/ssl/ca.crt"

vault login
```

Esto solicitará el token generado al haber inicializado vault.

Verificar acceso:

```bash
vault token lookup
```

> El root token debe utilizarse únicamente para tareas iniciales de administración. Después del bootstrap, se recomienda revocarlo o restringir su uso según el procedimiento operativo definido.

## Habilitar motor de secretos KV v2

Habilitar un motor de secretos KV versión 2:

```bash
vault secrets enable -path=kv kv-v2
```

Validar:

```bash
vault secrets list
```

Resultado esperado:

```bash
Path    Type
----    ----
kv/     kv
```


## 5. Habilitar autenticación por certificados

Habilitar el método de autenticación `cert`:

```bash
vault auth enable cert
```

Validar:

```bash
vault auth list
```

Resultado esperado:

```bash
Path      Type
----      ----
cert/     cert
```

## Resultado esperado

- Vault inicializado  
- Vault desellado  
- Motores habilitados  
- Autenticación configurada  


## Consideraciones de seguridad

- No almacenar unseal keys en Git  
- No almacenar root token en el repositorio  
- Limitar acceso a Vault  
- Utilizar autenticación basada en certificados  

## Resultado final

Al finalizar:

- Vault completamente operativo  
- Gestión de secretos habilitada  
- Acceso controlado mediante políticas  
- Integración con mTLS funcional  
