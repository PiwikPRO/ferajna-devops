## Redis - no so boring

Konstanty Karagiorgis

Marcin Malczewski

---

## Agenda

- what is it and general features
- replication - cluster and sentinel
- persistence

---
<!-- What is it section -->
### What is it

Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache, and message broker

---

<!-- General featurs -->
### General features

* k/v store for strings, sets, lists, hashes (map/dict)
* pubsub
* ACLs

---

<!-- Redis cluster section -->
### Clustering

Redis Cluster

----

#### Basic info

* sharding across nodes
* online resharding
* some degree of partition tolerance


----
#### Sharding

![https://miro.com/app/board/o9J_lLrOtDw=/](redis-cluster/topology-sharding.png)

----
#### Sharding - hash slots

Each key is assigned to one of 16384 hash slots. To compute hash slot for given key, we calculate CRC16 for given key and take its modulo 16384

----
#### Hash slots example

Hash slot ranges are distributed between the master nodes. For example if we have three master nodes, we can allocate the hash slots as follows:

* Master[0] -> Slots 0 - 5460
* Master[1] -> Slots 5461 - 10922
* Master[2] -> Slots 10923 - 16383

----
#### Hash slots allocation

Hash slots allocation is not automatic and must be configured when cluster is created. Assigning a hash slot to master node is done by connecting to the node and invoking `CLUSTER ADDSLOTS` command
```
# https://redis.io/commands/cluster-addslots

CLUSTER ADDSLOTS 1 2 3  # and so on
```

----
#### Sharding limitations 1

Clients connecting to Redis in cluster mode must be cluster aware, which means:

* The need to understand `MOVED` commands if the node the client would like to perform operation on is not able to complete it
* Hash slots awareness and CRC16 calculated on client side

----
#### Sharding limitations 2

Transactions, multiple key operations and LUA scripts can be only used with keys from the same hash slot. There is a possibility of enforcing placement on the same hash slot using hash tags (a `{...}` sub-string that happens to be identical for each key that should be placed on the same hash slot)

----
#### Replication model

![https://miro.com/app/board/o9J_lLrOtDw=/](redis-cluster/topology-replication.png)

----
#### Replication - replicas

* Each master node can have from 0 to n replicas (formerly slaves, currently both terms are used)
* Replicas can be be read from, providing that client explicitly declares, that it's `READONLY`. Otherwise all operations on replica will be `MOVED` to master, telling the client to reconnect
* In case of master failure, replica can be elected a new master for specific hash slots (failover)

----
#### Redis cluster demo

* `READONLY` and non-`READONLY` replica `GET` attempts
* replica `SET` attempt
* connecting via redis-cli with and without `-c` parameter, trying to fetch data outside of owned hash slot range


---

<!-- Redis sentinel section -->
### Clustering

Redis Sentinel

----

#### Basic info

* Clustering solution for Redis
* Master / replica (formerly slave) architecture
* Automatic failover when master fails


----

#### Replication diagram

![https://miro.com/app/board/o9J_lLrOtDw=/](redis-cluster/topology-sentinel.png)

----

#### Replication fundamentals

* Sentinel process is independent of Redis, can be even deployed on separate machine
* One sentinel can monitor multiple Redis clusters
* Sentinels form a clusters, where they select, monitor and configure Redis master and replicas

----
#### Replication configuration for replicas

Can be skipped if using `known-replicas` in sentinel

```
SLAVEOF 192.168.0.5 6379
```

----
#### Replication configuration for sentinel

```
sentinel monitor clustername 192.168.0.5 6379 2

# Can be skipped if using `SLAVEOF MASTER` in replica
sentinel known-slave clustername 192.168.0.6 6379
```

Sentinel detects other sentinels and replicas using redis pub/sub mechanism

----
#### Replication example


![https://miro.com/app/board/o9J_lLrOtDw=/](redis-cluster/failover-initial.png)

----
#### Replication example


![https://miro.com/app/board/o9J_lLrOtDw=/](redis-cluster/failover-partition.png)

----
#### Replication tuning

```
# Stop accepting writes if cannot write to this many replicas
min-slaves-to-write 1

# After that many time since key received
min-slaves-max-lag 30

# Also applicable in Redis Cluster!
```


---

<!-- Persistence section -->
### Persistence

To RDB or to AOF?

----
#### Redis Database

Point-in-time snapshots of your dataset at specified interval

* small size
* doesn't affect performance heavily
* it makes sense to perform the snapshot every x minutes, so not all data is persisted

----
#### Append only file

* flushes every write to disk in for of log
* can be synchronous or periodic, eg. every 1 second
* automatically rewritten after it gets big

---

### Questions