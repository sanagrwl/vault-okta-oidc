## Vault Okta OIDC example

#### Docs
Based on: [Okta and Vault setup guide from Hashicorp](https://developer.hashicorp.com/vault/tutorials/cloud-ops/vault-oidc-okta)

Single default role configured based on [github issue](https://github.com/hashicorp/vault/discussions/17763)

[Leveraging identity for auth methods with external groups](https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces#leveraging-identity-for-auth-methods-with-external-groups)

#### Setup

- Configures Okta using OIDC at path `okta` in `admin` namespace
- Creates `psec` namespace, child of `admin`
  - `admin` is the default namespace in HCP Vault that everything should be configured under.
  - All namespaces must be created under `admin` NS. No access to `root` namespace
- Creates policy for psec in `psec` namespace
  - A team policy exist in team's namespace
- Configures internal group in namepspsace `psec`
  - Maps to external group for psec in  `admin` namespace
  - psec okta group alias configured in `admin` namespace
- Maps vault admin group / alias to Okta group in `admin` namespace.

#### Gotchas / Findings
- When logging in with Okta, have to specify `admin` namespace always.
  - Can't do sub namespaces, `admin/psec` as Okta is configued in `admin` namespace.
  - Eg: `vault login -method=oidc -path=okta -namespace=admin`
- Using a single Okta default role, as policies are applied at group level.
  - Not sure if role per okta group buys much (audit?)
  - See: [github issue](https://github.com/hashicorp/vault/discussions/17763)
- What value does mapping internal okta group to external okta group in parent namespace provides? 
  - Clean policies. Policies doesn't have to specify full namespace paths. Eg: `admin/psec/secret/..` instead it can be just `secret/..`
  - Policies belong in team's namespaces. Parent namespaces are not cluttered.
  - Any other?
- Token information only provides `default` policy information, though NS specific policy is applied.
  - This is due to how group membership works for internal to external.
  - You won't see other policy applied via internal group here.
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

export VAULT_ADDR=""
export TF_VAR_vault_addr=$VAULT_ADDR
export VAULT_TOKEN=""
export VAULT_NAMESPACE="admin"
```

- tf plan
- tf apply
- tf destroy

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

