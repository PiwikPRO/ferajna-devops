#!/bin/sh

# login
vault login

# create policy that we attache later to approle
vault policy write dbpolicy /vault/policy.hcl

# enable database secret engine
vault secrets enable database

# Configure Vault with the proper plugin and connection information
# Config name have to be the same as database name
vault write database/config/vaulttestdb \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(db1:3306)/" \
    allowed_roles="my-role" \
    username="${MYSQL_ROOT_USER}" \
    password="${MYSQL_ROOT_PASSWORD}"

# user will be removed after 5min from database
vault write database/roles/my-role \
    db_name=vaulttestdb\
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="2m" \
    max_ttl="5m"

# auth method for vault (using role id and secret it)
vault auth enable approle
vault write auth/approle/role/dbwebapp policies="dbpolicy" role_id="${VAULT_ROLE_ID}"
vault write auth/approle/role/dbwebapp/custom-secret-id secret_id="${VAULT_SECRET_ID}"
