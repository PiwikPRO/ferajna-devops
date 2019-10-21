#!/bin/bash

command -v docker-compose >/dev/null 2>&1 || exit 1

DOCKER_DIR="$(pwd)/$(dirname "$0")"
DC_ARGS="-f ${DOCKER_DIR}/docker-compose.yml"
