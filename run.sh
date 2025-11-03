#!/bin/bash

docker compose up -d
CONTAINER_NAME=$(docker compose ps -q yocto)
docker exec -it $CONTAINER_NAME /bin/zsh
docker compose down