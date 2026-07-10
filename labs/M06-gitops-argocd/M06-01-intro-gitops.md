# M06-01 — Introducción a GitOps

[← Página anterior](README.md) · [Siguiente página →](M06-02-sincronizacion-automatica.md)

## Objetivo

Instalar **ArgoCD** en kind y desplegar la demo desde un `Application` que apunta a tu overlay Kustomize.

## Prerrequisitos

- M05 completado.
- Overlay Kustomize en `infra/kustomize/overlays/dev`.

---

### 1 — Instalar ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd wait --for=condition=available deployment/argocd-server --timeout=300s
```

---

### 2 — Modo insecure (Codespace)

El proxy de **Codespaces** termina TLS y habla HTTP con el port-forward. Argo CD, por defecto, redirige HTTP → HTTPS y entras en un bucle. Activa modo insecure **solo para el lab**:

```bash
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl -n argocd rollout restart deployment argocd-server
kubectl -n argocd rollout status deployment argocd-server --timeout=120s
```

---

### 3 — Acceso UI

```bash
kubectl -n argocd port-forward svc/argocd-server 8082:80 &
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

Abre el puerto **8082** en la pestaña **Ports** del Codespace. Usuario: `admin`.

Si usas la CLI: `argocd login localhost:8082 --plaintext --insecure`.

---

### 4 — Application manifest

Copia `infra/argocd/solutions/application-dev.yaml` a `infra/argocd/application-dev.yaml` y ajusta `repoURL` a **tu fork**.

```bash
kubectl apply -f infra/argocd/application-dev.yaml
argocd app sync cloudnative-demo-dev   # CLI opcional
```

---

### 5 — Verificar reconciliación

Cambia réplicas en Git → push → observa sync en UI ArgoCD.

---

→ **[M06-02 — Sincronización automática](M06-02-sincronizacion-automatica.md)**
