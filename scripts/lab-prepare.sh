#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="${1:-}"

API_PROPS="$ROOT/infra/app/api/src/main/resources/application.properties"
API_DOCKERFILE="$ROOT/infra/app/api/Dockerfile"
K8S_BASE="$ROOT/infra/k8s/base"

usage() {
  cat <<'EOF'
Uso: ./scripts/lab-prepare.sh <lab>

Labs disponibles:
  m02-01   application.properties en estado M01 (Spring Boot embebido)
  m02-02   application M02-01 + Dockerfile monolítico
  m03-01   estado post-M02 + limpia manifests K8s del alumno
  m04-01   post-M03 + limpia chart Helm del alumno
  m08-01   post-M06 + despliega stack observabilidad (solución)

El repo en main arranca en estado M01. Ejecuta lab-prepare si repites un lab
o tu fork ya tenía cambios aplicados.
EOF
}

copy_file() {
  local src="$1" dst="$2"
  cp "$src" "$dst"
  echo "  → $(realpath --relative-to="$ROOT" "$dst")"
}

reset_k8s_base() {
  rm -rf "$K8S_BASE"
  mkdir -p "$K8S_BASE"
  echo "  → infra/k8s/base/ (vacío para que implementes el lab)"
}

case "$LAB" in
  m02-01)
    echo "== Preparando M02-01 =="
    copy_file "$ROOT/infra/starters/application.m01.properties" "$API_PROPS"
    echo "OK: Spring Boot en estado M01 (config embebida)."
    ;;
  m02-02)
    echo "== Preparando M02-02 =="
    copy_file "$ROOT/infra/solutions/application.m02-01.properties" "$API_PROPS"
    copy_file "$ROOT/infra/starters/Dockerfile.m01" "$API_DOCKERFILE"
    echo "OK: application M02-01 + Dockerfile monolítico."
    ;;
  m03-01)
    echo "== Preparando M03-01 =="
    copy_file "$ROOT/infra/solutions/application.m02-01.properties" "$API_PROPS"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$API_DOCKERFILE"
    reset_k8s_base
    echo "OK: app post-M02 lista; carpeta K8s vacía para tus manifests."
    ;;
  m04-01)
    echo "== Preparando M04-01 =="
    copy_file "$ROOT/infra/solutions/application.m02-01.properties" "$API_PROPS"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$API_DOCKERFILE"
    if [[ -d "$ROOT/infra/helm/cloudnative-demo" ]]; then
      rm -rf "$ROOT/infra/helm/cloudnative-demo"
    fi
    echo "OK: sin chart Helm — lo crearás en M04-01."
    ;;
  m08-01)
    echo "== Preparando M08-01 =="
    copy_file "$ROOT/infra/solutions/application.m02-01.properties" "$API_PROPS"
    copy_file "$ROOT/infra/solutions/Dockerfile.m02-02" "$API_DOCKERFILE"
    echo "OK: app lista. Despliega observabilidad según M08-01."
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
