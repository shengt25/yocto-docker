#!/bin/bash

docker compose -f compose.yocto.yaml up -d
CONTAINER_NAME=$(docker compose -f compose.yocto.yaml ps -q yocto)
if [ -z "$CONTAINER_NAME" ]; then
    echo "Failed to get yocto container ID."
    echo "Maybe the container failed to start?"
    echo "Check with docker compose -f compose.yocto.yaml ps" 
    exit 1
fi
docker exec -it $CONTAINER_NAME /bin/zsh
docker compose -f compose.yocto.yaml stop
