# Parent groups (one per application)
resource "keycloak_group" "app" {
  for_each = local.app_roles

  realm_id = data.keycloak_realm.harvestasya.id
  name     = each.key
}

# Child groups (roles under each application)
resource "keycloak_group" "role" {
  for_each = {
    for item in local.all_roles : "${item.app}.${item.role}" => item
  }

  realm_id  = data.keycloak_realm.harvestasya.id
  parent_id = keycloak_group.app[each.value.app].id
  name      = each.value.role
}
