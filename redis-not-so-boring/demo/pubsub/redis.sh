#!/usr/bin/env bash

set -e

cd $(dirname $0)/..

source common/helm.sh
source common/kind.sh

function timestamp() {
    date +%s
}

function help(){

usage="
    $0 start - starts KIND kubernetes cluster and installs redis cluster onto it
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
        echo ">>> redis-cli -h cluster-redis-headless"
        echo ""
        kubectl run --namespace default cluster-redis-client-$(timestamp) --rm --tty -i --restart='Never' \
            --image docker.io/bitnami/redis-cluster:6.2.1-debian-10-r23 -- bash
    ;;
    start)
        $HELM_BINARY repo add bitnami https://charts.bitnami.com/bitnami
        $KIND_BINARY create cluster --name redis-server-demo
        $HELM_BINARY install cluster bitnami/redis \
            --set cluster.slaveCount=0 \
            --set usePassword=false
    ;;
    stop)
        $KIND_BINARY delete cluster --name redis-server-demo
    ;;
    *)
        echo "Unknown command ${COMMAND}. Should be one of: (connect|start|stop)";
        help;
        exit 1;
    ;;
esac