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
CRON_LOG_DIRECTORY=

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
    if [ -n "$CRON_LOG_DIRECTORY" ]; then
        rm -rf "$CRON_LOG_DIRECTORY"
    fi
}
trap cleanup EXIT

compose config --quiet
compose build --pull

run_image apache httpd -t
run_image apache sh -c 'test ! -s /usr/local/apache2/conf/extra/trusted-proxies.conf'

echo "Smoke: apache trusted proxy configuration"
docker run --rm \
    -e DOMAIN_NAME=example.com \
    -e TRUSTED_PROXY_CIDRS="203.0.113.0/24,2001:db8::/32" \
    -e TZ=UTC \
    "$(image_id apache)" \
    sh -c 'grep -Fx "RemoteIPHeader CF-Connecting-IP" /usr/local/apache2/conf/extra/trusted-proxies.conf && grep -Fx "RemoteIPTrustedProxy 203.0.113.0/24" /usr/local/apache2/conf/extra/trusted-proxies.conf && grep -Fx "RemoteIPTrustedProxy 2001:db8::/32" /usr/local/apache2/conf/extra/trusted-proxies.conf'

# shellcheck disable=SC2016
run_image php php -r '$required=["gd","imagick","zip","exif","gmp","mysqli","redis"]; $missing=array_filter($required, fn($extension)=>!extension_loaded($extension)); if ($missing) { fwrite(STDERR, "Missing PHP extensions: ".implode(", ", $missing).PHP_EOL); exit(1); } echo "PHP ".PHP_VERSION.PHP_EOL;'

run_image mariadb mariadbd --version
run_image redis redis-server --version
run_image cron sh -c 'command -v docker >/dev/null && command -v crond >/dev/null && command -v flock >/dev/null'

echo "Smoke: cron logging"
CRON_LOG_DIRECTORY=$(mktemp -d)
docker run --rm \
    -v "$CRON_LOG_DIRECTORY:/var/log" \
    "$(image_id cron)" \
    sh -c 'run-with-logging.sh failed false; status=$?; test "$status" -eq 1 && grep -Eq "\\[failed\\] exit=1$" /var/log/cron.log'
run_image logrotate logrotate --version
run_image_entrypoint certbot certbot --version
run_image_entrypoint certbot sh -c 'mkdir -p /var/www/certbot && certbot renew --webroot -w /var/www/certbot --dry-run --non-interactive --config-dir /tmp/letsencrypt --work-dir /tmp/work --logs-dir /tmp/logs'
run_image_entrypoint restic restic version

echo "Smoke test passed."
