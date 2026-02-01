output "app_groups" {
  description = "Parent application groups"
  value = {
    for name, group in keycloak_group.app : name => group.id
  }
}

output "role_groups" {
  description = "Role groups (app.role format)"
  value = {
    for key, group in keycloak_group.role : key => group.id
  }
}

output "groups_scope_id" {
  description = "Groups client scope ID"
  value       = keycloak_openid_client_scope.groups.id
}
