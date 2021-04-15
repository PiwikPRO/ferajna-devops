#!/usr/bin/env bash

set -e

KIND_VERSION="0.10.0"

if [ ! -f /tmp/kind-linux-${KIND_VERSION}-amd64 ]; then
    echo "\nDownloading Kind release..."
    curl -L https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64 -o /tmp/kind-linux-${KIND_VERSION}-amd64
fi

chmod +x /tmp/kind-linux-${KIND_VERSION}-amd64
export KIND_BINARY=/tmp/kind-linux-${KIND_VERSION}-amd64
