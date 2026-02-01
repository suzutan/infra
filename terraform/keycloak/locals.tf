# Group definitions based on BeyondCorp Permission Model v2.1.0
# See: docs/permission-models/BEYONDCORP-PERMISSION-MODEL.md

locals {
  # Application groups with their roles
  # Format: app_name = [list of roles]
  app_roles = {
    argocd     = ["admin", "viewer"]
    grafana    = ["admin", "editor", "viewer"]
    prometheus = ["viewer"]
    n8n        = ["admin", "editor"]
    traefik    = ["admin"]
    immich     = ["admin", "viewer"]
    navidrome  = ["admin", "viewer"]
    asf        = ["admin"]
    kubevela   = ["admin"]
    influxdb   = ["admin", "viewer"]
    keycloak   = ["admin"]
  }

  # Flatten to list of {app, role} for iteration
  all_roles = flatten([
    for app, roles in local.app_roles : [
      for role in roles : {
        app  = app
        role = role
      }
    ]
  ])
}
