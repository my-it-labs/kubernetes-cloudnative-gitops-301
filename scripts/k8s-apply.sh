#!/usr/bin/env bash
# Carga imágenes locales en kind y aplica manifests del alumno.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER="cloudnative-lab"
CONTEXT="kind-${CLUSTER}"
NAMESPACE="${NAMESPACE:-cloudnative-lab}"

echo "== Build imágenes demo =="
docker compose -f "$ROOT/infra/docker-compose.yml" build demo-api demo-web

echo "== Cargar en kind =="
kind load docker-image cloudnative-demo-api:latest --name "$CLUSTER" 2>/dev/null \
  || kind load docker-image infra-demo-api:latest --name "$CLUSTER" 2>/dev/null \
  || true

API_IMAGE="$(docker compose -f "$ROOT/infra/docker-compose.yml" images demo-api --format '{{.Repository}}:{{.Tag}}' | head -1)"
WEB_IMAGE="$(docker compose -f "$ROOT/infra/docker-compose.yml" images demo-web --format '{{.Repository}}:{{.Tag}}' | head -1)"

if [[ -n "$API_IMAGE" && "$API_IMAGE" != ":" ]]; then
  kind load docker-image "$API_IMAGE" --name "$CLUSTER"
fi
if [[ -n "$WEB_IMAGE" && "$WEB_IMAGE" != ":" ]]; then
  kind load docker-image "$WEB_IMAGE" --name "$CLUSTER"
fi

echo "== Aplicar manifests =="
kubectl --context "$CONTEXT" apply -f "$ROOT/infra/k8s/base/" -n "$NAMESPACE" 2>/dev/null \
  || kubectl --context "$CONTEXT" apply -f "$ROOT/infra/k8s/base/"

echo "OK: revisa con kubectl --context $CONTEXT -n $NAMESPACE get pods"
