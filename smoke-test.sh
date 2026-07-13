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
SMOKE_SECRETS_DIRECTORY=
MARIADB_BACKUP_DIRECTORY=
MARIADB_BACKUP_CONTAINER=invision-smoke-mariadb-backup
APACHE_START_CONTAINER=invision-smoke-apache-start
MIGRATION_DIRECTORY=

if [ -f .env ]; then
    ENV_ARGS=(--env-file .env)
elif [ -f dotenv ]; then
    ENV_ARGS=(--env-file dotenv)
fi

compose() {
    SECRETS_DIRECTORY="$SMOKE_SECRETS_DIRECTORY" "${DOCKER_COMPOSE[@]}" "${ENV_ARGS[@]}" -p "$PROJECT_NAME" "$@"
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

file_mode() {
    stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1"
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

smoke_apache_start() {
    echo "Smoke: apache default startup"
    docker run -d --rm \
        --name "$APACHE_START_CONTAINER" \
        -e DOMAIN_NAME=example.com \
        -e TZ=UTC \
        "$(image_id apache)" >/dev/null

    for _ in $(seq 1 10); do
        if docker exec "$APACHE_START_CONTAINER" bash -c 'exec 3<>/dev/tcp/127.0.0.1/80' >/dev/null 2>&1; then
            return
        fi
        sleep 0.5
    done

    docker logs "$APACHE_START_CONTAINER" >&2
    return 1
}

smoke_mariadb_backup_restore() {
    echo "Smoke: mariadb backup and restore"
    MARIADB_BACKUP_DIRECTORY=$(mktemp -d)

    docker run -d --rm \
        --name "$MARIADB_BACKUP_CONTAINER" \
        -e MARIADB_ROOT_PASSWORD_FILE=/run/secrets/mariadb_root_password \
        -e MARIADB_DATABASE=invision_smoke \
        -e MARIADB_USER=invision_smoke \
        -e MARIADB_PASSWORD_FILE=/run/secrets/mariadb_password \
        -v "$SMOKE_SECRETS_DIRECTORY:/run/secrets:ro" \
        -v "$MARIADB_BACKUP_DIRECTORY:/var/backup" \
        "$(image_id mariadb)" >/dev/null

    for _ in $(seq 1 60); do
        if docker exec "$MARIADB_BACKUP_CONTAINER" sh -c 'MYSQL_PWD="$(cat /run/secrets/mariadb_root_password)" mariadb -uroot -e "SELECT 1"' >/dev/null 2>&1; then
            break
        fi
        sleep 0.5
    done

    if ! docker exec "$MARIADB_BACKUP_CONTAINER" sh -c 'MYSQL_PWD="$(cat /run/secrets/mariadb_root_password)" mariadb -uroot -e "SELECT 1"' >/dev/null; then
        docker logs "$MARIADB_BACKUP_CONTAINER" >&2
        return 1
    fi

    docker exec "$MARIADB_BACKUP_CONTAINER" sh -c 'MYSQL_PWD="$(cat /run/secrets/mariadb_root_password)" mariadb -uroot invision_smoke -e "CREATE TABLE backup_check (value VARCHAR(32)); INSERT INTO backup_check VALUES (\"restored\");"'
    docker exec "$MARIADB_BACKUP_CONTAINER" create-backup.sh
    rg -q 'CREATE DATABASE.*invision_smoke' "$MARIADB_BACKUP_DIRECTORY/ips.sql"

    docker exec "$MARIADB_BACKUP_CONTAINER" sh -c 'MYSQL_PWD="$(cat /run/secrets/mariadb_root_password)" mariadb -uroot invision_smoke -e "DROP TABLE backup_check;"'
    docker exec "$MARIADB_BACKUP_CONTAINER" restore-backup.sh

    restored_value=$(docker exec "$MARIADB_BACKUP_CONTAINER" sh -c 'MYSQL_PWD="$(cat /run/secrets/mariadb_root_password)" mariadb -N -B -uroot invision_smoke -e "SELECT value FROM backup_check;"')
    test "$restored_value" = restored
}

smoke_secret_migration() {
    echo "Smoke: secret migration"
    MIGRATION_DIRECTORY=$(mktemp -d)

    printf '%s\n' \
        'MARIADB_ROOT_PASSWORD=smoke-root-password' \
        'MARIADB_PASSWORD=smoke-user-password' \
        'RESTIC_PASSWORD=smoke-restic-password' \
        'AWS_ACCESS_KEY_ID=smoke-access-key' \
        'AWS_SECRET_ACCESS_KEY=smoke-secret-access-key' > "$MIGRATION_DIRECTORY/.env"

    ./migrate-secrets.sh "$MIGRATION_DIRECTORY/.env" "$MIGRATION_DIRECTORY/secrets" >/dev/null
    rg -qFx "SECRETS_DIRECTORY=$MIGRATION_DIRECTORY/secrets" "$MIGRATION_DIRECTORY/.env"
    test "$(file_mode "$MIGRATION_DIRECTORY/secrets")" = 700
    test "$(file_mode "$MIGRATION_DIRECTORY/secrets/mariadb_root_password")" = 600
    test "$(<"$MIGRATION_DIRECTORY/secrets/mariadb_root_password")" = smoke-root-password
    test "$(<"$MIGRATION_DIRECTORY/secrets/mariadb_password")" = smoke-user-password
    test "$(<"$MIGRATION_DIRECTORY/secrets/restic_password")" = smoke-restic-password
    rg -qFx 'AWS_ACCESS_KEY_ID=smoke-access-key' "$MIGRATION_DIRECTORY/secrets/aws_credentials"
    rg -qFx 'AWS_SECRET_ACCESS_KEY=smoke-secret-access-key' "$MIGRATION_DIRECTORY/secrets/aws_credentials"
}

cleanup() {
    compose down --remove-orphans -v >/dev/null 2>&1 || true
    if [ -n "$CRON_LOG_DIRECTORY" ]; then
        rm -rf "$CRON_LOG_DIRECTORY"
    fi
    if [ -n "$SMOKE_SECRETS_DIRECTORY" ]; then
        rm -rf "$SMOKE_SECRETS_DIRECTORY"
    fi
    if [ -n "$MARIADB_BACKUP_DIRECTORY" ]; then
        rm -rf "$MARIADB_BACKUP_DIRECTORY"
    fi
    if [ -n "$MIGRATION_DIRECTORY" ]; then
        rm -rf "$MIGRATION_DIRECTORY"
    fi
    docker rm -f "$MARIADB_BACKUP_CONTAINER" >/dev/null 2>&1 || true
    docker rm -f "$APACHE_START_CONTAINER" >/dev/null 2>&1 || true
}
trap cleanup EXIT

smoke_secret_migration

SMOKE_SECRETS_DIRECTORY=$(mktemp -d)
printf '%s\n' 'smoke-mariadb-root-password' > "$SMOKE_SECRETS_DIRECTORY/mariadb_root_password"
printf '%s\n' 'smoke-mariadb-user-password' > "$SMOKE_SECRETS_DIRECTORY/mariadb_password"
printf '%s\n' 'smoke-restic-password' > "$SMOKE_SECRETS_DIRECTORY/restic_password"
printf '%s\n' \
    'AWS_ACCESS_KEY_ID=smoke-access-key' \
    'AWS_SECRET_ACCESS_KEY=smoke-secret-access-key' > "$SMOKE_SECRETS_DIRECTORY/aws_credentials"

compose config --quiet
compose build --pull

run_image apache httpd -t
smoke_apache_start
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
smoke_mariadb_backup_restore
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
echo "Smoke: restic"
docker run --rm \
    --entrypoint restic \
    -e RESTIC_REPOSITORY=s3:https://s3.amazonaws.com/smoke-bucket \
    -e RESTIC_PASSWORD_FILE=/run/secrets/restic_password \
    -e AWS_CREDENTIALS_FILE=/run/secrets/aws_credentials \
    -v "$SMOKE_SECRETS_DIRECTORY:/run/secrets:ro" \
    "$(image_id restic)" \
    version

echo "Smoke: restic credential loading"
docker run --rm \
    --entrypoint sh \
    -e RESTIC_REPOSITORY=s3:https://s3.amazonaws.com/smoke-bucket \
    -e RESTIC_PASSWORD_FILE=/run/secrets/restic_password \
    -e AWS_CREDENTIALS_FILE=/run/secrets/aws_credentials \
    -v "$SMOKE_SECRETS_DIRECTORY:/run/secrets:ro" \
    "$(image_id restic)" \
    -c /usr/local/bin/restic-credentials.sh

echo "Smoke test passed."
