# Progresión del código en los laboratorios

Los alumnos implementan cambios **paso a paso**. El repositorio no debe entregar el resultado final en `main`.

## Modelo

```text
main (rama Python) — fork del alumno
  └── api.py + Dockerfile en estado M01

M02-01  →  el alumno edita api.py (config + /ready)
M02-02  →  el alumno reescribe Dockerfile (multistage)
M03+    →  manifiestos K8s, Helm, CI/CD, GitOps, observabilidad
```

Rama `springboot`: mismo temario con **Spring Boot + Angular**.

| Carpeta | Contenido |
|---------|-----------|
| `infra/starters/` | Copias del estado **inicial** de cada fase |
| `infra/solutions/` | Referencia del estado **esperado al terminar** |
| `infra/app/api/` | Ficheros **activos** que el alumno modifica |

## Scripts

| Script | Cuándo |
|--------|--------|
| `./scripts/lab-prepare.sh m02-01` | Antes de M02-01 — restaura api.py a M01 |
| `./scripts/lab-prepare.sh m02-02` | Antes de M02-02 — api M02-01 + Dockerfile monolítico |
| `./scripts/lab-prepare.sh m03-01` | Antes de M03 — estado completo post-M02 |
| `./scripts/lab-verify.sh m02-01` | Al terminar M02-01 |
| `./scripts/lab-verify.sh m02-02` | Al terminar M02-02 |

## Forks antiguos

Si un alumno hizo fork cuando `main` ya tenía todo implementado:

1. `git pull` en su fork (o resincronizar con upstream).
2. `./scripts/lab-prepare.sh m02-01` antes de empezar M02.

## Regla para nuevos módulos

Al redactar un lab que pida «implementa X»:

1. `main` no debe incluir X.
2. Añadir starter en `infra/starters/` si hace falta reset.
3. Añadir solución en `infra/solutions/` para verificación.
4. Paso «Antes de empezar» con `lab-prepare.sh`.
5. Paso final con `lab-verify.sh` (o comprobación explícita).

---

[← Volver al índice del curso](../README.md)
