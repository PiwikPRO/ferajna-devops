#!/bin/bash

. "$(pwd)/$(dirname "$0")"/init.sh
. ${DOCKER_DIR}/wait-for-container.sh

function start_databases {
  echo "Running databases..."
  docker-compose ${DC_ARGS} up -d db1

  waitForContainerLogEntry db1 "ready for connections" 180

  while :
  do
    echo "Waiting for user test connection on db1.."
    sleep 1
    docker-compose ${DC_ARGS} exec db1 mysql -u test -ptest -NBe "show status" 2> /dev/null 1>&2
    if [ $? -eq 0 ]; then
      echo "\nBreaking..."
      break
    fi
  done
}

function start_vault_server {
  echo "Running vault server..."
  docker-compose ${DC_ARGS} up -d vault-server

  waitForContainerLogEntry vault-server "Vault server configuration" 180

  # initialize vault server
  docker-compose ${DC_ARGS} exec vault-server vault operator init | tee vault_token.log
  # unseal
  docker-compose ${DC_ARGS} exec vault-server vault operator unseal
  docker-compose ${DC_ARGS} exec vault-server vault operator unseal
  docker-compose ${DC_ARGS} exec vault-server vault operator unseal
  # load configuration
  docker-compose ${DC_ARGS} exec vault-server /vault/configuration.sh
}

function start_vault_agent {
  echo "Running vault agent..."
  docker-compose ${DC_ARGS} up -d vault-agent

  waitForContainerLogEntry vault-agent "Vault agent configuration" 180
}

function start_vault_client {
  echo "Running vault client..."
  docker-compose ${DC_ARGS} up -d vault-client

  waitForContainerLogEntry vault-client "Vault server started" 180
}

start_databases
start_vault_server
start_vault_agent
start_vault_client
