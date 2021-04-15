#!/usr/bin/env bash

set -e

cd $(dirname $0)/..

source common/helm.sh
source common/kind.sh

function help(){

usage="
  $0 start - starts KIND kubernetes cluster and installs redis sentinel onto it
  $0 stop - destroys KIND kubernetes cluster
  $0 connect - starts client pod and prints connection command
"
echo "${usage}"
}

COMMAND=${1}
[[ -z "${COMMAND}" ]] && { echo "COMMAND parameter (connect|start|stop) not specified"; help; }

shift
case "${COMMAND}" in
  help)
    help
    ;;
  connect)
    echo "After bash prompt is shown, please run:"
    echo ">>> redis-cli -h sentinel-redis"
    echo ""
    kubectl run --namespace default sentinel-redis-client --rm --tty -i --restart='Never' \
        --image docker.io/bitnami/redis:6.0.12-debian-10-r3 -- bash
    ;;
  start)
    $HELM_BINARY repo add bitnami https://charts.bitnami.com/bitnami
    $KIND_BINARY create cluster --name redis-sentinel-demo
    $HELM_BINARY install sentinel bitnami/redis --set sentinel.enabled=true \
      --set cluster.slaveCount=3 \
      --set usePassword=false
    ;;
  stop)
    $KIND_BINARY delete cluster --name redis-sentinel-demo
    ;;
  *)
    echo "Unknown command ${COMMAND}. Should be one of: (connect|start|stop)";
    help;
    exit 1;
    ;;
esac