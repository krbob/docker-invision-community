#!/bin/bash
set -euo pipefail

if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE=(docker compose)
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE=(docker-compose)
else
    echo "Docker Compose is required."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not available. Start Docker and rerun ./smoke-test.sh."
    exit 1
fi

PROJECT_NAME=${SMOKE_PROJECT_NAME:-invision-smoke}
ENV_ARGS=()

if [ -f .env ]; then
    ENV_ARGS=(--env-file .env)
elif [ -f dotenv ]; then
    ENV_ARGS=(--env-file dotenv)
fi

compose() {
    "${DOCKER_COMPOSE[@]}" "${ENV_ARGS[@]}" -p "$PROJECT_NAME" "$@"
}

image_id() {
    local service=$1
    local image="${PROJECT_NAME}-${service}:latest"

    if ! docker image inspect "$image" >/dev/null 2>&1; then
        echo "Image for service '$service' was not found."
        exit 1
    fi

    echo "$image"
}

run_image() {
    local service=$1
    shift

    echo "Smoke: $service"
    docker run --rm \
        -e DOMAIN_NAME=example.com \
        -e TZ=UTC \
        "$(image_id "$service")" "$@"
}

run_image_entrypoint() {
    local service=$1
    local entrypoint=$2
    shift 2

    echo "Smoke: $service"
    docker run --rm \
        -e DOMAIN_NAME=example.com \
        -e TZ=UTC \
        --entrypoint "$entrypoint" \
        "$(image_id "$service")" "$@"
}

cleanup() {
    compose down --remove-orphans -v >/dev/null 2>&1 || true
}
trap cleanup EXIT

compose config --quiet
compose build --pull

run_image apache httpd -t

# shellcheck disable=SC2016
run_image php php -r '$required=["gd","imagick","zip","exif","gmp","mysqli","redis"]; $missing=array_filter($required, fn($extension)=>!extension_loaded($extension)); if ($missing) { fwrite(STDERR, "Missing PHP extensions: ".implode(", ", $missing).PHP_EOL); exit(1); } echo "PHP ".PHP_VERSION.PHP_EOL;'

run_image mariadb mariadbd --version
run_image redis redis-server --version
run_image cron sh -c 'command -v docker >/dev/null && command -v crond >/dev/null'
run_image logrotate logrotate --version
run_image_entrypoint certbot certbot --version
run_image_entrypoint certbot sh -c 'mkdir -p /var/www/certbot && certbot renew --webroot -w /var/www/certbot --dry-run --non-interactive --config-dir /tmp/letsencrypt --work-dir /tmp/work --logs-dir /tmp/logs'
run_image_entrypoint restic restic version

echo "Smoke test passed."
