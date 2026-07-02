# Puntos de partida de laboratorios (`infra/starters/`)

Copias de referencia del **estado inicial** de cada fase. Los scripts `lab-prepare.sh` las restauran sobre los ficheros activos en `infra/app/api/`.

| Fichero | Estado | Usado en |
|---------|--------|----------|
| `application.m01.properties` | JDBC/redis embebidos, sin probes | M02-01 |
| `Dockerfile.m01` | Maven monolítico | M02-02 |

No edites estos ficheros durante los labs: trabaja sobre `infra/app/api/src/main/resources/application.properties` y `infra/app/api/Dockerfile`.
