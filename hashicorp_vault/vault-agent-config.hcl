exit_after_auth = false
pid_file = "/vault/pidfile"

auto_auth {
   method "approle" {
       mount_path = "auth/approle"
       config = {
           role_id_file_path = "/vault/vault-role-id"
           secret_id_file_path = "/vault/vault-secret-id"
           remove_secret_id_file_after_reading = false
       }
   }

   sink "file" {
       config = {
           path = "/vault/approleToken"
       }
   }
}

cache {
   use_auto_auth_token = true
}

listener "tcp" {
   address = "0.0.0.0:8007"
   tls_disable = true
}

vault {
   address = "http://vault-server:8200"
}
