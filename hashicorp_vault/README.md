# Simple test environment for hashicorp vault
* mariadb 10.3 (db1)
* vault server (vault-server)
* vault agent (vault-agent)
* vault client (vault-client)

## How it works
* ./start.sh to start environment
  - create single database nose
  - crate vault server
    - initialize vault
    - unseal (provide 3 keys)
    - login to vault (provide root token)
    - load configuration
  - create vault agent
    - Enable auto auth by login to vault server using approle role id and secret id
    - enable caching
  - create vault client
  - create vault_token.log (with root token)
  - vault UI http://172.16.2.20:8200
* ./stop.sh to clean up docker the mess

## Usage
### Scenario 1
Console 1 - vault server logs
```
docker logs -f hashicorpvault_vault-server_1
```

Console 2 - mysql users list
```
watch 'docker exec -it hashicorpvault_db1_1 mysql -u root -proot -Ne "select user,password from mysql.user"'

```

Console 3 - vault client shell
```
docker exec -it hashicorpvault_vault-client_1 /bin/sh
# check environments
> env

# login to vault server password: test123
> vault login -method=userpass username=test

# generate mysql user and password (will be removed from DB after 2min - default ttl)
# each command generate new user
> vault read database/creds/my-role

```
### Scenario 2
Console 1 - vault agent logs
```
docker logs -f hashicorpvault_vault-agent_1
```

Console 2 - mysql users list
```
watch 'docker exec -it hashicorpvault_db1_1 mysql -u root -proot -Ne "select user,password from mysql.user"'
```

Console 3 - vault client shell
```
docker exec -it hashicorpvault_vault-client_1 /bin/sh

# configure client to use vault agent
> export VAULT_AGENT_ADDR="http://vault-agent:8007"

# generate mysql user and password (will be removed from DB after 5min - vault agent renew them to max_ttl)
> vault read database/creds/my-role

# generate file with credentials using consul-template
> ./consul-template -template "/vault/demo.ctmpl:/vault/demo.txt" -once

```
