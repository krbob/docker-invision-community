#!/bin/bash

if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

dockerfiles=$(find . -name Dockerfile)

for dockerfile in $dockerfiles; do
    for image in $(grep FROM $dockerfile | awk '{print $2}'); do
        if ! docker pull $image; then
            echo "Failed to pull image $image. Exiting..."
            exit 1
        fi
    done
done

if ! $DOCKER_COMPOSE up --build -d --remove-orphans; then
    echo "$DOCKER_COMPOSE up failed. Exiting..."
    exit 1
fi

docker image prune -af
