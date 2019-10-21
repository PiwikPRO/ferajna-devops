path "auth/approle/login" {
  capabilities = ["create", "read"]
}

path "database/creds/my-role" {
  capabilities = ["read"]
}
