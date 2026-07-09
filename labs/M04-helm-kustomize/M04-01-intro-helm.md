# M04-01 — Introducción a Helm

[← Página anterior](README.md) · [Siguiente página →](M04-02-parametrizacion-helm.md)

## Objetivo

Crear un **chart Helm** para empaquetar la demo **Flask + nginx** y sustituir los YAML sueltos de M03.

## Prerrequisitos

- M03 completado (namespace `cloudnative-lab` y manifests en kind).

> [!IMPORTANT]
> **No pongas `templates/namespace.yaml` en el chart.**
>
> El namespace `cloudnative-lab` **ya lo creaste en M03** con `kubectl`. Si el chart intenta crear el mismo Namespace, Helm falla con *invalid ownership metadata* / *cannot be imported into the current release*.
>
> El chart solo despliega recursos **dentro** del namespace existente (`helm install -n cloudnative-lab`). Usa `{{ .Values.namespace }}` en Deployments/Services, no un objeto `Kind: Namespace`.

## Antes de empezar

```bash
./scripts/lab-prepare.sh m04-01
kubectl get namespace cloudnative-lab   # debe existir desde M03
```

Referencia: `infra/helm/solutions/cloudnative-demo/`.

## Mapa del ejercicio

```text
Paso 1   Estructura del chart (sin Namespace template)
Paso 2   Templates Deployment/Service API y Web
Paso 3   values.yaml con imágenes locales
Paso 4   helm install -n cloudnative-lab
```

---

### 1 — Crear el chart

```bash
mkdir -p infra/helm
helm create infra/helm/cloudnative-demo
```

Elimina templates de ejemplo (nginx, etc.) y **elimina también `templates/namespace.yaml`** si `helm create` lo generó. Conserva `Chart.yaml`, `values.yaml`, `templates/` (solo app).

---

### 2 — Plantillas mínimas

Traslada tus manifests M03 a templates Helm con `{{ .Values.api.image }}`, `{{ .Values.namespace }}`, etc.

Archivos mínimos:

- `templates/api.yaml` (Deployment + Service + ConfigMap + Secret si agrupas)
- `templates/web.yaml`
- `templates/redis.yaml`, `postgres.yaml` (opcional flags `.Values.redis.enabled`)

**No incluyas** `templates/namespace.yaml`.

---

### 3 — values.yaml

```yaml
namespace: cloudnative-lab
api:
  image: cloudnative-demo-api:local
  replicas: 2
web:
  image: cloudnative-demo-web:local
  nodePort: 30080
```

`namespace` en values es para `metadata.namespace` de tus recursos, no para crear el Namespace.

---

### 4 — Instalar

```bash
helm lint infra/helm/cloudnative-demo
helm upgrade --install cloudnative-demo infra/helm/cloudnative-demo \
  -n cloudnative-lab
kubectl -n cloudnative-lab get pods
./scripts/lab-verify.sh m04-01
```

O con el script del curso:

```bash
./scripts/helm-install.sh cloudnative-demo cloudnative-lab
```

---

## Errores frecuentes

| Error | Causa | Arreglo |
|-------|-------|---------|
| `Namespace "cloudnative-lab" exists and cannot be imported into the current release` | Chart con `templates/namespace.yaml` y el ns ya existe (M03) | Borra ese template; instala solo con `-n cloudnative-lab` |
| `missing key "app.kubernetes.io/managed-by": Helm` | Helm quiere «adoptar» un ns creado por kubectl | Igual: no gestiones el Namespace desde el chart |
| `helm list` vacío pero falla install | Mismo conflicto en primer install | Quita Namespace del chart; no hace falta borrar el ns |

---

## Comprueba tu entendimiento

**¿Helm vs YAML plano?**

→ Chart versionado, valores por entorno, releases con historial (`helm history`).

**¿Por qué el namespace no va en el chart?**

→ En este curso el ns es infraestructura compartida (M03); Helm despliega la **app** dentro, no recrea el ns.

→ **[M04-02 — Parametrización](M04-02-parametrizacion-helm.md)**
