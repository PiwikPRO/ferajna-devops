#
- Seal/Unseal
  - Vault must decrypt the encryption key which requires the master key
  - The master key isn't stored anywhere.
#
- auth method
#
- Secret Engines
#
- Policies
#
- Vault Agent
  - Auto-auth
  - Caching
# 
- Dev mode

# Use Cases
- No more credentials in application environment 
- No more password/token rotation
- Unique credentials per service (even per container of service)
- Simple credentials rotation rotation
- Dynamically generated API key for cloud providers (e.g. AWS access key can be generated for the duration of a script, then revoked )
- Data encryption ( where you store your key? - vault centralized key management)

