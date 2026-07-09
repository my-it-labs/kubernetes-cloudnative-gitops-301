# M04-02 — Parametrización con Helm

[← Página anterior](M04-01-intro-helm.md) · [Siguiente página →](M04-03-kustomize.md)

## Objetivo

Parametrizar réplicas, nombres de servicio y recursos con `values.yaml` (dentro del chart) y **overrides por entorno fuera del chart**.

## Antes de empezar

```bash
./scripts/lab-prepare.sh m04-02
mkdir -p infra/helm/environments
```

El chart queda en `infra/helm/cloudnative-demo/`. Los values de entorno van en **`infra/helm/environments/`** (carpeta hermana, no dentro del chart).

## Estructura

```text
infra/helm/
├── cloudnative-demo/          # Chart (values.yaml por defecto)
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── environments/              # Overrides por entorno (M04-02)
    ├── values-dev.yaml
    └── values-staging.yaml
```

---

### 1 — values por entorno (solo las diferencias)

El chart ya trae **`values.yaml`** con los valores por defecto. Helm **lo carga automáticamente**; no hace falta `-f values.yaml`.

Crea **`infra/helm/environments/values-dev.yaml`** (fuera del chart):

```yaml
api:
  replicas: 1
config:
  serviceName: cloudnative-demo-api-dev
```

Crea **`infra/helm/environments/values-staging.yaml`** con `replicas: 2` y otro `serviceName`.

Referencia: `infra/helm/solutions/environments/`.

---

### 2 — Upgrade con overrides (capas de values)

**Concepto:** Helm fusiona valores en este orden (los últimos ganan):

```text
1. values.yaml del chart              ← automático (dentro del chart)
2. -f infra/helm/environments/...     ← override de entorno (fuera)
3. --set api.replicas=3               ← override puntual en CLI
```

**Acción — desplegar con values de desarrollo:**

```bash
helm upgrade --install cloudnative-demo infra/helm/cloudnative-demo \
  -n cloudnative-lab \
  -f infra/helm/environments/values-dev.yaml
```

Para staging:

```bash
helm upgrade --install cloudnative-demo infra/helm/cloudnative-demo \
  -n cloudnative-lab \
  -f infra/helm/environments/values-staging.yaml
```

**Override puntual en línea de comandos:**

```bash
helm upgrade --install cloudnative-demo infra/helm/cloudnative-demo \
  -n cloudnative-lab \
  -f infra/helm/environments/values-dev.yaml \
  --set api.replicas=2
```

`--set` tiene prioridad sobre los `-f`.

Verifica el ConfigMap generado:

```bash
kubectl -n cloudnative-lab get configmap demo-api-config -o yaml | grep SERVICE_NAME
```

**Resultado esperado:** `SERVICE_NAME` refleja el entorno (`...-dev` o `...-staging`).

---

### 3 — Historial y rollback Helm

```bash
helm history cloudnative-demo -n cloudnative-lab
helm rollback cloudnative-demo 1 -n cloudnative-lab
```

**Por qué:** Mismo concepto que `kubectl rollout`, pero a nivel de **release** Helm.

---

### 4 — Recursos y límites

Añade en `infra/helm/environments/values-dev.yaml` (o en el `values.yaml` base si aplica a todos):

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
