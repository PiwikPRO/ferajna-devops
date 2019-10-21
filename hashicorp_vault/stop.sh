#!/bin/bash

. "$(pwd)/$(dirname "$0")"/init.sh

function clean_docker_compose {
  echo "Cleaning up..."
  docker-compose ${DC_ARGS} down -v
}

clean_docker_compose
