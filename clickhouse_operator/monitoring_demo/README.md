# ClickHouse operator monitoring demo 

## Prerequisites

1. Kubernetes cluster - can be a local [k3d](https://k3d.io/) or [kind](https://kind.sigs.k8s.io/)
2. Configured kubectl to use it

## Install ClickHouse Operator

Clone ClickHouse Operator repository:
```
git clone https://github.com/Altinity/clickhouse-operator.git
```

Install ClickHouse operator:
```
kubectl apply -f clickhouse-operator/deploy/operator/clickhouse-operator-install.yaml
```

Add ClickHouse cluster:
```
kubectl apply -f simple-cluster.yaml
```

## Setup monitoring 

[More information](https://github.com/Altinity/clickhouse-operator/blob/master/docs/monitoring_setup.md)

### Prometheus

Install ClickHouse operator:
```
clickhouse-operator/deploy/prometheus/create-prometheus.sh
```

[More information](https://github.com/Altinity/clickhouse-operator/blob/master/docs/prometheus_setup.md)

### Alerting

Add alerting rules
```
kubectl apply --namespace=prometheus -f clickhouse-operator/deploy/prometheus/prometheus-alert-rules.yaml
```

### Grafana

Install Grafana operator:
```
clickhouse-operator/deploy/grafana/grafana-with-grafana-operator/install-grafana-operator.sh
```

Add Grafana dashboard from ClickHouse operator:
```
clickhouse-operator/deploy/grafana/grafana-with-grafana-operator/install-grafana-with-operator.sh
```

[More information](https://github.com/Altinity/clickhouse-operator/blob/master/docs/grafana_setup.md)

## How to

### Enter ClickHouse

Enter ClickHouse client  on container:
```
kubectl exec -ti chi-ferajna-default-0-0-0 clickhouse-client
```

### Enter Prometheus

Forward port:
```
kubectl --namespace=grafana port-forward service/grafana-service 9090
```
Enter in a browser: http://localhost:9090

### Enter Grafana

Forward port:
```
kubectl --namespace=grafana port-forward service/grafana-service 3000
```
Enter in a browser (login: `admin`, password: `admin`): http://localhost:3000

### Add data to cluster

ClickHouse provides few datasets with detailed info how to add them, you can read about it [here](https://clickhouse.tech/docs/en/getting-started/example-datasets/)

## Automated version

If you do not want to setup everything manually you can run the following automated scripts:
```
./setup.sh
./add-data.sh
./make-some-noise.sh
```
