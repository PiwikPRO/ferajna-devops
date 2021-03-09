#!/bin/bash
set -e

k3d cluster delete ferajna

k3d cluster create ferajna

kubectl config use-context k3d-ferajna

if [ ! -d "clickhouse-operator/" ] 
then
    git clone https://github.com/Altinity/clickhouse-operator.git
fi

kubectl apply -f clickhouse-operator/deploy/operator/clickhouse-operator-install.yaml
kubectl apply -f monitoring-simple-cluster.yaml

clickhouse-operator/deploy/prometheus/create-prometheus.sh

kubectl apply --namespace=prometheus -f clickhouse-operator/deploy/prometheus/prometheus-alert-rules.yaml

clickhouse-operator/deploy/grafana/grafana-with-grafana-operator/install-grafana-operator.sh

clickhouse-operator/deploy/grafana/grafana-with-grafana-operator/install-grafana-with-operator.sh
