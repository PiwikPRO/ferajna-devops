# ClickHouse operator demo

## Prerequisites

1. Kubernetes cluster - can be a local [k3d](https://k3d.io/) or [kind](https://kind.sigs.k8s.io/)
2. Configured kubectl to use it
3. `clickHouse-client` - it should be available in your system repo

## Install ClickHouse Operator

Clone ClickHouse Operator repository:
```
git clone https://github.com/Altinity/clickhouse-operator.git
```

Set namespace for ClickHouse Operator:
```
export OPERATOR_NAMESPACE="default"
```

Install ClickHouse Operator:
```
clickhouse-operator/deploy/operator/clickhouse-operator-install.sh
```

Install ZooKeeper:
```
clickhouse-operator/deploy/zookeeper/quick-start-persistent-volume/zookeeper-1-node-create.sh
```

Add ClickHouse cluster:
```
kubectl apply -f ferajna.yaml
```

Wait until nodes will be provisioned, and now it is time to forward port needed for connection:
```
kubectl port-forward chi-ferajna-default-0-0-0 9000
```

Create schema, you will be need `clickhouse-client`:
```
clickhouse-client -m -n < schema.sql
```

Load some data:
```
clickhouse-client --database="ferajna" --query "INSERT INTO events FORMAT TSV" < data.tsv
```
