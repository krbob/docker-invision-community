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

docker compose up --build -d

docker image prune -af
