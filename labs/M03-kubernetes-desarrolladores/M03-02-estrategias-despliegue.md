# M03-02 — Estrategias de despliegue

[← Página anterior](M03-01-diseno-despliegue.md) · [Siguiente página →](M03-03-persistencia-postgresql.md)

## Objetivo

Practicar **rolling update**, detectar una versión mala y hacer **rollback** sobre el Deployment de la API Spring Boot.

## Prerrequisitos

- M03-01 completado (API desplegada en `cloudnative-lab`).

## Antes de empezar

```bash
kubectl -n cloudnative-lab get deploy demo-api
```

## Mapa del ejercicio

```text
Paso 1   Observar ReplicaSet actual
Paso 2   Rolling update (cambio de imagen o env)
Paso 3   Simular fallo (probe o imagen rota)
Paso 4   Rollback con kubectl rollout
```

---

### 1 — Estado inicial

```bash
kubectl -n cloudnative-lab get deploy,rs,pods -l app=demo-api
kubectl -n cloudnative-lab describe deploy demo-api | grep -A5 "RollingUpdate"
```

**Por qué:** Kubernetes actualiza Pods de forma gradual para mantener disponibilidad.

---

### 2 — Rolling update por variable

**Acción:** Cambia `SERVICE_NAME` en el ConfigMap a `cloudnative-demo-api-v2` y aplica:

```bash
kubectl -n cloudnative-lab edit configmap demo-api-config
kubectl -n cloudnative-lab rollout restart deployment/demo-api
kubectl -n cloudnative-lab rollout status deployment/demo-api
curl -s http://127.0.0.1:8081/actuator/health  # vía port-forward si hace falta
```

**Resultado esperado:** Nuevo ReplicaSet; Pods antiguos terminan tras los nuevos estar Ready.

---

### 3 — Simular despliegue fallido

**Acción:** Edita el Deployment y pon `image: cloudnative-demo-api:broken` (tag inexistente).

```bash
kubectl -n cloudnative-lab set image deployment/demo-api api=cloudnative-demo-api:broken
kubectl -n cloudnative-lab get pods -l app=demo-api
```

**Resultado esperado:** Nuevos Pods en `ImagePullBackOff` o `ErrImagePull`; el rollout no completa.

---

### 4 — Rollback

```bash
kubectl -n cloudnative-lab rollout undo deployment/demo-api
kubectl -n cloudnative-lab rollout status deployment/demo-api
kubectl -n cloudnative-lab rollout history deployment/demo-api
```

**Por qué:** `rollout undo` vuelve al ReplicaSet anterior — patrón operativo en producción.

---

## Reto

Induce un fallo de **readiness** (para Postgres en M03-03) y observa que el Service no envía tráfico a Pods no Ready.

## Errores frecuentes

| Síntoma | Arreglo |
|---------|---------|
| Rollout atascado | `kubectl rollout undo` o corrige manifest |
| Dos ReplicaSets activos | Normal durante update; espera o revisa `maxUnavailable` |

→ **[M03-03 — Persistencia PostgreSQL](M03-03-persistencia-postgresql.md)**
