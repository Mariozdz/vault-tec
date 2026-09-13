# Prerrequisitos

## Requisitos del sistema

Se recomienda un entorno con:

- Sistema operativo: Linux, macOS o Windows (con WSL)
- CPU: mínimo 4 núcleos
- RAM: mínimo 8 GB
- Docker en ejecución

## Herramientas requeridas

### Docker

Utilizado por Kind para crear el cluster.

Verificación:

```bash
docker --version
```


### Kind

Herramienta para crear clusters Kubernetes locales.

Verificación:

```bash
kind --version
```

### kubectl

CLI para interactuar con Kubernetes.

Verificación:

```bash
kubectl version --client
```


### OpenSSL

Utilizado para trabajar con certificados.

Verificación:

```bash
openssl version
```


## Acceso al repositorio

Debe contar con acceso al repositorio Git que contiene la implementación.

```bash
git clone <repo-url>  
cd <repo>
```


## Consideraciones importantes

- No se deben almacenar secretos en el repositorio
- Solo certificados públicos pueden versionarse
- Las llaves privadas deben mantenerse fuera de Git
- El repositorio actúa como fuente de verdad (GitOps)


## Validación del entorno

Ejecutar:

```bash
docker ps  
kind --version  
kubectl version --client
```

## Resultado esperado

- Todas las herramientas instaladas correctamente
- Docker funcionando
- Acceso al repositorio disponible
- Entorno listo para crear el cluster

