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
}


### Start: psec team setup
resource "vault_jwt_auth_backend_role" "vault-role-okta-group-vault-team-psec" {
    # role for okta group: okta-group-vault-team-psec
    backend         = vault_jwt_auth_backend.okta.path
    role_name       = "vault-role-okta-group-vault-team-psec"
    user_claim            = "sub"
    role_type             = "oidc"
    bound_audiences       = [ var.okta_client_id ]
    allowed_redirect_uris = ["${var.vault_addr}/ui/vault/auth/${vault_jwt_auth_backend.okta.path}/oidc/callback", "http://localhost:8250/oidc/callback" ]
    token_policies  = ["default"]
    oidc_scopes = [ "groups" ]
    groups_claim = "groups"
}

resource "vault_policy" "vault-policy-team-psec" {
  name = "vault-policy-team-psec"

  policy = <<EOT
# Read permission on the k/v secrets
path "/secret/psec/*" {
    capabilities = ["read","create","update","delete","list"]
}
EOT
}

resource "vault_identity_group" "okta-group-vault-team-psec" {
  name     = "okta-group-vault-team-psec"
  type     = "external"
  policies = [ vault_policy.vault-policy-team-psec.name ]

  metadata = {
    responsibility="okta-group-vault-team-psec"
  }
}

resource "vault_identity_group_alias" "okta-group-vault-team-psec" {
  name           = "okta-group-vault-team-psec" # this must match okta group
  mount_accessor = vault_jwt_auth_backend.okta.accessor
  canonical_id   = vault_identity_group.okta-group-vault-team-psec.id
}

# ### End: psec team setup