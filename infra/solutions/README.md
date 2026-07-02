# Soluciones de referencia (`infra/solutions/`)

Estado **esperado al terminar** cada bloque de labs. Úsalas para:

- Comparar tu trabajo (`diff infra/solutions/application.m02-01.properties infra/app/api/src/main/resources/application.properties`)
- Recuperarte si te atascas (`cp infra/solutions/...` solo como último recurso)
- Preparar M03 si saltaste M02 (`./scripts/lab-prepare.sh m03-01`)

| Fichero | Tras completar |
|---------|----------------|
| `application.m02-01.properties` | M02-01 — config externalizada + Actuator probes |
| `Dockerfile.m02-02` | M02-02 — multistage Maven + JRE + `USER app` |

Prefiere `./scripts/lab-verify.sh` antes de mirar la solución completa.
