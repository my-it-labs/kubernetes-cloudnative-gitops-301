#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CTX="${KUBE_CONTEXT:-kind-cloudnative-lab}"
OBS="$ROOT/infra/observability/solutions"

echo "== Observabilidad (solución M08) =="
kubectl --context "$CTX" apply -f "$OBS/namespace.yaml"
kubectl --context "$CTX" apply -f "$OBS/prometheus.yaml"
kubectl --context "$CTX" apply -f "$OBS/grafana.yaml"
echo "Prometheus NodePort 30090 | Grafana NodePort 30300 (admin/lab)"
