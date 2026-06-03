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

while IFS= read -r dockerfile; do
    while IFS= read -r image; do
        if ! docker pull "$image"; then
            echo "Failed to pull image $image. Exiting..."
            exit 1
        fi
    done < <(awk '$1 == "FROM" { print $2 }' "$dockerfile")
done < <(find . -name Dockerfile)

if ! "${DOCKER_COMPOSE[@]}" up --build -d --remove-orphans; then
    echo "${DOCKER_COMPOSE[*]} up failed. Exiting..."
    exit 1
fi

docker image prune -f
