# M03 — Kubernetes para desarrolladores (avanzado)

[← Página anterior](../M02-docker-avanzado-cloudnative/M02-02-optimizacion-imagenes.md) · [Siguiente página →](M03-01-diseno-despliegue.md)

## Qué aprenderás

- Modelar Deployments, Services y recursos básicos en Kubernetes.
- Aplicar rolling updates, simular fallos y hacer rollback.
- Gestionar estado con volúmenes persistentes y PostgreSQL.

## Teoría

Kubernetes declara el **estado deseado**. Deployments gestionan réplicas; Services exponen tráfico; PersistentVolumeClaims guardan datos más allá del ciclo de vida del Pod.

En los laboratorios desplegarás la **API Spring Boot** y el **frontend Angular** en kind, aplicarás rolling updates y añadirás PostgreSQL con volumen persistente.

## Scripts útiles

| Script | Módulo |
|--------|--------|
| `./scripts/k8s-apply.sh` | Cargar imágenes en kind y aplicar `infra/k8s/base/` |
| `./scripts/lab-prepare.sh m03-01` | Estado post-M02 + carpeta K8s vacía |

## Ahora practica tú

| Lab | Título | Temario |
|-----|--------|---------|
| M03-01 | [Diseño de despliegue](M03-01-diseno-despliegue.md) | LAB 3 |
| M03-02 | [Estrategias de despliegue](M03-02-estrategias-despliegue.md) | LAB 4 |
| M03-03 | [Persistencia y PostgreSQL](M03-03-persistencia-postgresql.md) | LAB 5 |

→ Empieza por **[M03-01](M03-01-diseno-despliegue.md)**.
