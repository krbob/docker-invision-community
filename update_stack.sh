#!/bin/bash

dockerfiles=$(find . -name Dockerfile)

for dockerfile in $dockerfiles; do
    for image in $(grep FROM $dockerfile | awk '{print $2}'); do
        docker pull $image
    done
done

docker compose up --build -d

docker image prune -af
