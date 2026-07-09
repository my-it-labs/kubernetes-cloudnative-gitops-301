#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHART="$ROOT/infra/helm/cloudnative-demo"
RELEASE="${1:-cloudnative-demo}"
NAMESPACE="${2:-cloudnative-lab}"

helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  "${@:3}"
