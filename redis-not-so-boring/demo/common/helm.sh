#!/usr/bin/env bash

set -e

HELM_VERSION="3.5.3"

if [ ! -f /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz ]; then
    echo "\nDownloading Helm release..."
    curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz
fi


if [ ! -f /tmp/linux-amd64/helm ]; then
    echo "\nExtracting Helm release..."
    cd /tmp && tar -xvzf /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz && cd -
fi

export HELM_BINARY=/tmp/linux-amd64/helm
