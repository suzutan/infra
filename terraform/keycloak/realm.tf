# Use existing realm (created manually)
data "keycloak_realm" "harvestasya" {
  realm = var.realm_name
}
