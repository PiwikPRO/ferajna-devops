# PubSub and LUA example

## Requirements

- [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html) installed
- redis server working on `localhost:6379` - you can use `redis.sh` and forward proper port

    ```bash
    ./redis.sh start
    kubectl port-forward svc/cluster-redis-headless 6379
    ```

## PubSub

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
    ./redis.sh connect
    > redis-cli -h cluster-redis-headless
    >>> SUBSCRIBE pubsub
    ```

- Publish new message

    ```bash
    curl localhost:5000/publish
    ```

    Both clients should receive published message

## LUA

- Connect to redis

```bash
./redis.sh connect
```

- Create LUA script

```bash
cat << EOF > /tmp/example.lua
redis.call('ECHO', 'Increment all subcounters in ' .. KEYS[1])
local count=0
local broadcast=redis.call("LRANGE", KEYS[1], 0,-1)
for _,key in ipairs(broadcast) do
    redis.call("INCR",key)
    redis.call('ECHO', 'Increment counter ' .. key)
    count=count+1
end
return count
EOF
```

- create test counters

```bash
> redis-cli -h cluster-redis-headless
RPUSH region:eu-west count:ireland count:london count:paris
MGET count:ireland
MGET count:london
MGET count:paris
```

- run script

```bash
redis-cli -c -h cluster-redis-headless --eval /tmp/example.lua region:eu-west
```

- check updated counters

```bash
> redis-cli -h cluster-redis-headless
MGET count:ireland
MGET count:london
MGET count:paris
```