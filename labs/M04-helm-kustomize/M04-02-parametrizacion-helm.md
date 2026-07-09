# M04-02 — Parametrización con Helm

[← Página anterior](M04-01-intro-helm.md) · [Siguiente página →](M04-03-kustomize.md)

## Objetivo

Parametrizar réplicas, nombres de servicio y recursos con `values.yaml` y overrides por línea de comandos.

## Antes de empezar

```bash
./scripts/lab-prepare.sh m04-02
```

El chart solución ya está en `infra/helm/cloudnative-demo/` (sin `values-dev` / `values-staging` — los creas en el paso 1).

### 1 — values por entorno (solo las diferencias)

El chart ya trae **`values.yaml`** con los valores por defecto (imágenes, puertos, redis, etc.). Helm **lo carga automáticamente** en cada `install` / `upgrade`; no hace falta pasarlo con `-f`.

Los ficheros por entorno (`values-dev.yaml`, `values-staging.yaml`) deben contener **solo lo que cambia** respecto a la base:

Crea `infra/helm/cloudnative-demo/values-dev.yaml`:

```yaml
api:
  replicas: 1
config:
  serviceName: cloudnative-demo-api-dev
```

Crea `values-staging.yaml` con `replicas: 2` y otro `serviceName`.

Referencia: `infra/helm/solutions/values-dev.yaml` y `values-staging.yaml`.

---

### 2 — Upgrade con overrides (capas de values)

**Concepto:** Helm fusiona valores en este orden (los últimos ganan si hay clave repetida):

```text
1. values.yaml del chart          ← siempre (por defecto, sin -f)
2. -f values-dev.yaml           ← override de entorno
3. --set api.replicas=3         ← override puntual en CLI (opcional)
```

**No repitas** `-f values.yaml`: confunde «base» con «override». La base ya está en el chart.

**Acción — desplegar con values de desarrollo:**

```bash
helm upgrade --install cloudnative-demo infra/helm/cloudnative-demo \
  -n cloudnative-lab \
  -f infra/helm/cloudnative-demo/values-dev.yaml
```

Para staging, cambia el último `-f` por `values-staging.yaml`.

**Override puntual en línea de comandos** (sin editar ficheros):

```bash
helm upgrade cloudnative-demo infra/helm/cloudnative-demo \
  -n cloudnative-lab \
  -f infra/helm/cloudnative-demo/values-dev.yaml \
  --set api.replicas=2
```

`--set` tiene prioridad sobre los `-f`.

Verifica el ConfigMap generado:

```bash
kubectl -n cloudnative-lab get configmap demo-api-config -o yaml | grep SERVICE_NAME
```

**Resultado esperado:** `SERVICE_NAME` refleja el entorno (`...-dev` o `...-staging`), no el valor por defecto del `values.yaml` base.

---

### 3 — Historial y rollback Helm

```bash
helm history cloudnative-demo -n cloudnative-lab
helm rollback cloudnative-demo 1 -n cloudnative-lab
```

**Por qué:** Mismo concepto que `kubectl rollout`, pero a nivel de **release** Helm.

---

### 4 — Recursos y límites

Añade en values:

```yaml
api:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      memory: 512Mi
```

Template con `{{ .Values.api.resources }}` en el contenedor.

---

→ **[M04-03 — Kustomize](M04-03-kustomize.md)**

```bash
./scripts/lab-verify.sh m04-02
```
