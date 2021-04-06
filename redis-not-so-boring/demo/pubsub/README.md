# PubSub example

## Requirements

- [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html) installed
- redis server working on `localhost:6379` - you can use `cluster.sh` from [cluster demo](../cluster/cluster.sh) and forward proper port

    ```bash
    ../cluster/cluster.sh start
    kubectl port-forward svc/cluster-redis-cluster 6379
    ```

## Usage

- Install dependencies

    ```bash
    pip install -r requirements.txt
    ```

- Run server - this will start simple http server on `localhost:5000`

    ```bash
    ./server.sh
    ```

- Connect to stream url (client1)

    ```bash
    curl -v localhost:5000/stream
    ```

- Subscribe in redis cli (client2)

    ```bash
    ../cluster/cluster.sh connect
    > redis-cli -c -h cluster-redis-cluster
    >>> SUBSCRIBE pubsub
    ```

- Publish new message

    ```bash
    curl localhost:5000/publish
    ```

    Both clients should receive published message