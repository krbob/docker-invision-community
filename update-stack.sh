#!/bin/bash

dockerfiles=$(find . -name Dockerfile)

for dockerfile in $dockerfiles; do
    for image in $(grep FROM $dockerfile | awk '{print $2}'); do
        if ! docker pull $image; then
            echo "Failed to pull image $image. Exiting..."
            exit 1
        fi
    done
done

if ! docker compose up --build -d --remove-orphans; then
    echo "docker compose up failed. Exiting..."
    exit 1
fi

docker image prune -af
