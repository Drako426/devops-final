#!/usr/bin/env bash
set -u

mkdir -p reportes

echo "=== 1. Ejecutando Gitleaks ==="
docker run --rm -v "$(pwd):/repo" zricethezav/gitleaks:latest detect \
  --source="/repo" --no-git --exit-code 0 \
  --report-format json --report-path "/repo/reportes/gitleaks-report.json" || true

echo "=== 2. Ejecutando Semgrep ==="
docker run --rm -v "$(pwd):/src" semgrep/semgrep:latest semgrep scan \
  --config=auto /src/app --json -o /src/reportes/semgrep-report.json || true

echo "=== 3. Ejecutando Hadolint ==="
docker run --rm -i hadolint/hadolint:latest < Dockerfile > reportes/hadolint-report.txt || true

echo "=== 4. Ejecutando Syft (SBOM) ==="
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/reportes:/reportes" anchore/syft:latest \
  est35-api:latest -o cyclonedx-json=/reportes/sbom.json || true

echo "=== 5. Ejecutando Trivy ==="
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/reportes:/reportes" aquasec/trivy:latest image \
  --format json --output /reportes/trivy-report.json est35-api:latest || true

monitorear() {
  local FECHA
  FECHA=$(date "+%Y-%m-%d %H:%M:%S")
  local URL="http://localhost:8035/health"
  local ESTADO_HTTP
  ESTADO_HTTP=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")

  {
    echo "=========================================="
    echo "Fecha de verificacion: $FECHA"
    if [ "$ESTADO_HTTP" = "200" ]; then
      echo "Estado API ($URL): OK (HTTP 200)"
    else
      echo "Estado API ($URL): ERROR (HTTP $ESTADO_HTTP)"
    fi
    echo "--- Estado de contenedores ---"
    docker ps --filter "name=est35_" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo "--- Ultimos 10 logs de est35_api ---"
    docker logs --tail 10 est35_api 2>&1
    echo ""
  } | tee -a monitoreo.log
}

echo "=== 6. Ejecutando monitoreo ==="
monitorear
