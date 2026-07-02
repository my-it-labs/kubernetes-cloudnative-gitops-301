#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="${1:-}"
PROPS="$ROOT/infra/app/api/src/main/resources/application.properties"
DOCKERFILE="$ROOT/infra/app/api/Dockerfile"

usage() {
  cat <<'EOF'
Uso: ./scripts/lab-verify.sh <lab>

Labs disponibles:
  m02-01   application.properties externalizado + probes Actuator
  m02-02   Dockerfile multistage Spring Boot + usuario no-root
  m03-01   manifests base mínimos en infra/k8s/base/
  m04-01   chart Helm cloudnative-demo instalable
EOF
}

ok()   { echo "OK: $*"; }
fail() { echo "FALTA: $*" >&2; errors=$((errors + 1)); }

errors=0

case "$LAB" in
  m02-01)
    echo "== Verificando M02-01 =="
    grep -q 'spring.datasource.url=\${SPRING_DATASOURCE_URL}' "$PROPS" \
      || fail "falta spring.datasource.url externalizada sin default"
    grep -q 'management.endpoint.health.probes.enabled=true' "$PROPS" \
      || fail "faltan probes de Actuator (readiness/liveness)"
    grep -q 'jdbc:postgresql://postgres' "$PROPS" \
      && fail "DATABASE_URL/JDBC sigue hardcodeada en application.properties"
    if [[ "$errors" -eq 0 ]]; then
      ok "application.properties cumple M02-01"
    fi
    ;;
  m02-02)
    echo "== Verificando M02-02 =="
    grep -q 'AS builder' "$DOCKERFILE" || fail "Dockerfile sin stage builder"
    grep -q 'AS runtime' "$DOCKERFILE" || fail "Dockerfile sin stage runtime"
    grep -q 'COPY --from=builder' "$DOCKERFILE" || fail "falta COPY --from=builder"
    grep -q 'USER app' "$DOCKERFILE" || fail "falta USER app"
    if [[ "$errors" -eq 0 ]]; then
      ok "Dockerfile cumple M02-02"
    fi
    ;;
  m03-01)
    echo "== Verificando M03-01 =="
    for f in namespace.yaml api-deployment.yaml api-service.yaml web-deployment.yaml web-service.yaml; do
      [[ -f "$ROOT/infra/k8s/base/$f" ]] || fail "falta infra/k8s/base/$f"
    done
    grep -q 'kind: Deployment' "$ROOT/infra/k8s/base/api-deployment.yaml" 2>/dev/null \
      || fail "api-deployment.yaml incompleto"
  if [[ "$errors" -eq 0 ]]; then
      ok "manifests base M03-01 presentes"
    fi
    ;;
  m04-01)
    echo "== Verificando M04-01 =="
    [[ -f "$ROOT/infra/helm/cloudnative-demo/Chart.yaml" ]] \
      || fail "falta infra/helm/cloudnative-demo/Chart.yaml"
    [[ -f "$ROOT/infra/helm/cloudnative-demo/values.yaml" ]] \
      || fail "falta values.yaml"
    if [[ "$errors" -eq 0 ]]; then
      ok "chart Helm cloudnative-demo presente"
    fi
    ;;
  -h|--help|"")
    usage
    exit "${1:+0}"
    ;;
  *)
    echo "Lab desconocido: $LAB" >&2
    usage
    exit 1
    ;;
esac

exit "$errors"
