# M02-01 — Adaptación cloudnative (Spring Boot)

[← Página anterior](README.md) · [Siguiente página →](M02-02-optimizacion-imagenes.md)

> Práctica del módulo. Stack del curso: **API Spring Boot** + **frontend Angular**.

## Objetivo

Externalizar la configuración de la API para que **una sola imagen JAR** funcione en distintos entornos cambiando variables en runtime.

## Prerrequisitos

- M01 completado (`./scripts/lab-up.sh` responde OK).
- Haber leído en el README: *Configuración vs código* y *Health vs Ready*.

## Antes de empezar

```bash
./scripts/lab-prepare.sh m02-01
./scripts/lab-up.sh
```

Comprueba el punto de partida (estado M01):

```bash
grep jdbc:postgresql infra/app/api/src/main/resources/application.properties
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8081/actuator/health/readiness
# → 404 o no expuesto (correcto en M01)
```

## Mapa del ejercicio

```text
Paso 1–2   Revisar y externalizar application.properties
Paso 3     Habilitar probes Actuator (liveness/readiness)
Paso 4     Conectar variables vía infra/.env + Compose
Paso 5–6   Validar y simular otro entorno
Paso 7     lab-verify.sh m02-01
```

---

### 1 — Revisar el acoplamiento actual

**Acción:** Abre `infra/app/api/src/main/resources/application.properties`. En M01 verás valores literales:

```properties
spring.datasource.url=jdbc:postgresql://postgres:5432/lab
spring.datasource.username=lab
spring.datasource.password=lab
spring.data.redis.host=redis
```

**Por qué:** En Spring Boot esto es el equivalente a constantes en código — la imagen queda ligada a un entorno.

---

### 2 — Externalizar con placeholders

**Acción:** Sustituye por variables de entorno (patrón objetivo en `infra/solutions/application.m02-01.properties`):

```properties
server.port=${PORT:8081}
spring.application.name=${SERVICE_NAME:cloudnative-demo-api}

spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

spring.data.redis.host=${SPRING_DATA_REDIS_HOST:redis}
spring.data.redis.port=${SPRING_DATA_REDIS_PORT:6379}

lab.slow-seconds=${LAB_SLOW_SECONDS:3}
```

**Por qué:** `${SPRING_DATASOURCE_URL}` **sin default** → fail fast si falta config en producción.

**Resultado esperado:** `grep jdbc:postgresql://postgres` en `application.properties` no devuelve líneas (solo en comentarios).

---

### 3 — Probes Actuator

**Acción:** Añade:

```properties
management.endpoint.health.probes.enabled=true
management.health.livenessstate.enabled=true
management.health.readinessstate.enabled=true
management.endpoints.web.exposure.include=health,info,prometheus
```

**Por qué:** Spring Boot expone:

- **Liveness** → `/actuator/health/liveness`
- **Readiness** → `/actuator/health/readiness` (incluye Redis + JDBC si están configurados)

Kubernetes, ECS y Azure Container Apps consumen estos endpoints.

---

### 4 — Variables en Compose

```bash
cp infra/.env.example infra/.env
cat infra/.env
```

Compose inyecta `env_file` en `demo-api`. Spring Boot mapea `SPRING_DATASOURCE_*` automáticamente.

---

### 5 — Reconstruir y validar

```bash
./scripts/lab-down.sh
./scripts/lab-up.sh
curl -s http://127.0.0.1:8081/actuator/health/liveness | jq .
curl -s http://127.0.0.1:8081/actuator/health/readiness | jq .
curl -s http://127.0.0.1:8081/work | jq .
```

Abre el frontend Angular (puerto 8080) y prueba los botones de health/readiness.

---

### 6 — Otro entorno sin recompilar

Edita `SERVICE_NAME` en `infra/.env` y recrea solo la API:

```bash
docker compose -f infra/docker-compose.yml up -d --force-recreate demo-api
```

---

### 7 — Verificar

```bash
./scripts/lab-verify.sh m02-01
```

---

## Errores frecuentes

| Síntoma | Arreglo |
|---------|---------|
| `Failed to configure DataSource` | Falta `.env` o variables JDBC |
| Readiness DOWN | Postgres/Redis arrancando — espera y repite |
| Angular no conecta | API en 8081; en nginx prod el proxy es `/api/` |

→ **[M02-02 — Optimización de imágenes](M02-02-optimizacion-imagenes.md)**
