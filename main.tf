resource "vault_jwt_auth_backend" "okta" {
    # Enable OIDC auth for Okta integration
    description         = "Demo of the OIDC auth backend with Okta"
    path                = "okta"
    type                = "oidc"
    oidc_discovery_url  = "https://${var.okta_domain}"
    oidc_client_id      = var.okta_client_id
    oidc_client_secret  = var.okta_client_secret
    default_role        = "vault-role-okta-default"
}

resource "vault_jwt_auth_backend_role" "vault-role-okta-default" {
    # default role for okta
    backend         = vault_jwt_auth_backend.okta.path
    role_name       = "vault-role-okta-default"
    user_claim            = "sub"
    role_type             = "oidc"
    bound_audiences       = [ var.okta_client_id ]
    allowed_redirect_uris = ["${var.vault_addr}/ui/vault/auth/${vault_jwt_auth_backend.okta.path}/oidc/callback", "http://localhost:8250/oidc/callback" ]
    token_policies  = ["default"]
    oidc_scopes = [ "groups" ]
    groups_claim = "groups"

}


### Start: psec team setup
resource "vault_namespace" "psec" {
    path = "psec"
}

resource "vault_mount" "psec_kv_engine" {
  namespace = vault_namespace.psec.path_fq
  path      = "secret"
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_policy" "vault-policy-team-psec" {
  name = "vault-policy-team-psec"
  namespace = vault_namespace.psec.path_fq

  policy = <<EOT
# permission to manage secrets in namespace
path "${vault_mount.psec_kv_engine.path}/*" {
    capabilities = ["read","create","update","delete","list"]
}

# for UI, with KV2, need additional token capabilities.
# https://discuss.hashicorp.com/t/getting-permission-denied-when-using-a-token-generated-in-hashicorp-vault/36645/3

# Allow tokens to look up their own properties
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
  capabilities = ["update"]
}

# Allow a token to look up its own capabilities on a path
path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_identity_group" "psec-team" {
  name     = "psec-team"
  type     = "external"

  metadata = {
    responsibility="okta-group-vault-team-psec"
  }
}

resource "vault_identity_group_alias" "okta-group-vault-team-psec" {
  name           = "okta-group-vault-team-psec" # this must match okta group
  mount_accessor = vault_jwt_auth_backend.okta.accessor
  canonical_id   = vault_identity_group.psec-team.id
}

resource "vault_identity_group" "psec-team-ns-group" {
  name     = "psec-team-ns-group"
  type = "internal"
  namespace = vault_namespace.psec.path_fq
  member_group_ids = [ vault_identity_group.psec-team.id ]
  policies = [ vault_policy.vault-policy-team-psec.name ]
}


#### End: psec team setup


#### Start: admin setup

resource "vault_policy" "vault-policy-admin" {
  name = "vault-policy-admin"

  policy = <<EOT
path "*" {
    capabilities = ["sudo","read","create","update","delete","list","patch"]
}
EOT
}

resource "vault_identity_group" "vault-admin" {
  name     = "vault-admin"
  type     = "external"
  policies = [ vault_policy.vault-policy-admin.name ]

  metadata = {
    responsibility="okta-group-vault-admin"
  }
}

resource "vault_identity_group_alias" "okta-group-vault-admins" {
  name           = "okta-group-vault-admins" # this must match okta group
  mount_accessor = vault_jwt_auth_backend.okta.accessor
  canonical_id   = vault_identity_group.vault-admin.id
}
#### End: admin setup