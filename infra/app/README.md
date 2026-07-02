# Aplicación demo — Spring Boot + Angular

Stack del curso (core de los alumnos):

| Componente | Ruta | Tecnología |
|------------|------|------------|
| **API** | `api/` | Spring Boot 3, Java 21, Actuator, JDBC, Redis |
| **Web** | `web/` | Angular 19, nginx en producción |
| **Compose** | `../docker-compose.yml` | Orquestación local M01–M02 |
| **Config** | `../.env.example` | Variables Spring (`SPRING_DATASOURCE_*`, etc.) |

## Progresión del código

| Módulo | Cambio que implementa el alumno |
|--------|-------------------------------|
| M01 | Exploración — `application.properties` con JDBC embebido |
| M02-01 | Externalizar config + probes Actuator |
| M02-02 | Dockerfile multistage Maven → JRE |
| M03+ | Manifiestos K8s, Helm, CI/CD, GitOps, observabilidad |

Ver `docs/progresion-labs.md` y scripts `lab-prepare.sh` / `lab-verify.sh`.

## Endpoints API (Spring Boot)

| Ruta | Uso |
|------|-----|
| `/actuator/health/liveness` | Liveness (M02+) |
| `/actuator/health/readiness` | Readiness + DB/Redis |
| `/actuator/prometheus` | Métricas M08 |
| `/work`, `/slow`, `/fail` | Labs carga y diagnóstico |

## Arranque local

```bash
cp infra/.env.example infra/.env
./scripts/lab-up.sh
# Web Angular: http://localhost:8080
# API: http://localhost:8081/actuator/health
```
