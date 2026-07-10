# Problemas frecuentes

## Codespace no arranca o va lento

- Usa un Codespace con **al menos 8 GB RAM** (observabilidad + kind).
- Cierra procesos innecesarios; en M08 el stack ELK consume mucha memoria.

## `kind create cluster` falla

```bash
docker info
./scripts/kind-down.sh
./scripts/kind-up.sh
```

## kubectl: contexto incorrecto

```bash
kubectl config use-context kind-cloudnative-lab
kubectl get nodes
```

## No puedo hacer push a GHCR (M05)

- Comprueba permisos del workflow en tu fork (`Settings → Actions → General`).
- El `GITHUB_TOKEN` del workflow necesita permiso `packages: write`.

## Firewall corporativo

Debe permitir: `github.com`, `*.githubusercontent.com`, `ghcr.io`, `hub.docker.com`, repos públicos del curso.

## Argo CD: bucle de redirección (M06)

Síntoma: al abrir la UI de Argo CD desde **Ports** (Codespace) la página redirige sin parar.

Causa: el proxy del Codespace habla HTTP con el port-forward; Argo CD fuerza HTTPS por defecto.

Solución (ver paso 2 de [M06-01](M06-gitops-argocd/M06-01-intro-gitops.md)):

```bash
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl -n argocd rollout restart deployment argocd-server
kubectl -n argocd rollout status deployment argocd-server --timeout=120s
kubectl -n argocd port-forward svc/argocd-server 8082:80 &
```

## AKS (M07)

El módulo M07 es **solo lectura comparativa**. No despliegas en Azure en este curso.
