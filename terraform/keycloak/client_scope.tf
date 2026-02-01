# Groups client scope for OIDC clients
resource "keycloak_openid_client_scope" "groups" {
  realm_id               = data.keycloak_realm.harvestasya.id
  name                   = "groups"
  description            = "Group membership claim for RBAC"
  include_in_token_scope = true
}

# Group membership mapper
resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
  realm_id        = data.keycloak_realm.harvestasya.id
  client_scope_id = keycloak_openid_client_scope.groups.id
  name            = "groups"

  claim_name          = "groups"
  full_path           = false
  add_to_id_token     = true
  add_to_access_token = true
  add_to_userinfo     = true
}
