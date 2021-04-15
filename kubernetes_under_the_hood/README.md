## Kubernetes under the hood

### Presentation (PL)
[link](presentation.pdf)

### Demo
This demo uses kind cluster in defult setup, but all these steps (except first one, with clustuer creation) should work on every working k8s cluster.
- create simple cluster: `kind create cluster`
- redirect api server to port 8888: `kubectl proxy --port 8888`
- get list of pods using curl (previous step is required): `curl http://127.0.0.1:8888/api/v1/pods`
- get all keys from etcd:
    ```
    # First check etcd IP and paths to ca, cert, key
    kubectl -n kube-system describe pod etcd
    kubectl -n kube-system exec -it etcd-kind-control-plane /bin/sh
    etcdctl --endpoints 172.21.0.2:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key get "" --prefix=true --keys-only
    ```
- get information about api server pod directly from etcd:
    ```
    etcdctl --endpoints 172.21.0.2:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key get /registry/pods/kube-system/kube-apiserver-kind-control-plane
    ```
- create pod with NodeSelector disktype=ssd: `kubectl apply -f nginx.yaml`
- check why it is not running (Events section at the bottom): `kubectl describe pod nginx`
- check exisiting labels on nodes: `kubectl get nodes --show-labels`
- add required label do node: `kubectl label nodes kind-control-plane disktype=ssd`
- ensure that pod works: `kubectl get pods`
- remove label from node: `kubectl label nodes kind-control-plane disktype-`
- ensure that pod still works: `kubectl get pods` / `kubectl describe pod nginx`

