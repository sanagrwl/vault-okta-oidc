## Vault Okta OIDC example

Based on: [Okta and Vault setup guide from Hashicorp](https://developer.hashicorp.com/vault/tutorials/cloud-ops/vault-oidc-okta)


#### Steps

Have the following environment variables set
```bash
export TF_VAR_okta_domain=""
export TF_VAR_okta_client_id=""
export TF_VAR_okta_client_secret=""

export OKTA_DOMAIN=$TF_VAR_okta_domain
export OKTA_CLIENT_ID=$TF_VAR_okta_client_id
export OKTA_CLIENT_SECRET=$TF_VAR_okta_client_secret

export VAULT_ADDR=""
export TF_VAR_vault_addr=$VAULT_ADDR
export VAULT_TOKEN=""
export VAULT_NAMESPACE="admin"

```

- tf plan
- tf apply
- vault login -method=oidc -namespace=admin role="vault-role-okta-group-vault-team-psec"

- tf destroy #cleanup
