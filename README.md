## Vault Okta OIDC example

#### Docs
Based on: [Okta and Vault setup guide from Hashicorp](https://developer.hashicorp.com/vault/tutorials/cloud-ops/vault-oidc-okta)

Single default role configured based on [github issue](https://github.com/hashicorp/vault/discussions/17763)

[Leveraging identity for auth methods with external groups](https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces#leveraging-identity-for-auth-methods-with-external-groups)

#### Setup

1. Configures Okta using OIDC at path `okta` in `admin` namespace
2. Creates `psec` namespace, child of `admin`
  - `admin` is the default namespace in HCP Vault that everything should be configured under.
  - All namespaces must be created under `admin` NS. No access to `root` namespace
3. Creates policy for psec in `psec` namespace
  - A team policy exist in team's namespace
4. Configures internal group in namepspsace `psec`
  - Maps to external group for psec in  `admin` namespace
  - psec okta group alias configured in `admin` namespace
5. Maps vault admin group / alias to Okta group in `admin` namespace.

#### Gotchas / Findings
1. When logging in with Okta, have to specify `admin` namespace always.
  - Can't do sub namespaces, `admin/psec` as Okta is configued in `admin` namespace.
2. Token information only provides `default` policy information, though NS specific policy is applied.
  - This is due to how group membership works for internal to external.

```bash
Key                  Value
---                  -----
token                ...
token_accessor       ...
token_duration       1h
token_renewable      true
token_policies       ["default"]
identity_policies    []
policies             ["default"]
token_meta_role      vault-role-okta-default
```


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
- tf destroy #cleanup

#### CLI Login

In new terminal

```bash
export VAULT_ADDR=""
```

CLI Login
```bash
vault login -method=oidc -path=okta -namespace=admin
```

UI login
- Select OIDC
- Namespace: admin
- More options: Mount path: Okta

