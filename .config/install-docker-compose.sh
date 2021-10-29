#!/usr/bin/env bash

sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -SL https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# check for smoke
docker compose version

if [[ $? -eq 0 ]]; then
    echo "Docker Compose V2 installed"
fi