
locals {
  role_grafana_admin_users = [
    "suzutan",
  ]
  role_grafana_editor_users = [
    "razz0408",
  ]
  role_grafana_viewer_users = [

  ]
}

resource "github_team" "grafana_admin_users" {
  name                      = "grafana-admin"
  description               = "grafana role:admin user"
  privacy                   = "secret"
  create_default_maintainer = false
}
resource "github_team_membership" "grafana_admin_users" {
  for_each = toset(local.role_grafana_admin_users)
  team_id  = github_team.grafana_admin_users.id
  username = each.value
  role     = "maintainer"
}

resource "github_team" "grafana_editor_users" {
  name                      = "grafana-editor"
  description               = "grafana role:editor user"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "grafana_editor_users" {
  for_each = toset(local.role_grafana_admin_users)
  team_id  = github_team.grafana_editor_users.id
  username = each.value
  role     = "maintainer"
}
resource "github_team" "grafana_viewer_users" {
  name                      = "grafana-viewer"
  description               = "grafana role:viewer user"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "grafana_viewer_users" {
  for_each = toset(local.role_grafana_admin_users)
  team_id  = github_team.grafana_viewer_users.id
  username = each.value
  role     = "maintainer"
}



resource "cloudflare_record" "grafana" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "grafana-v3"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_access_application" "grafana" {
  zone_id                   = data.cloudflare_zone.domain.id
  name                      = "grafana"
  domain                    = cloudflare_record.grafana.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_access_identity_provider.github.id]
}

resource "cloudflare_access_group" "grafana" {
  account_id = var.cloudflare_account_id
  name       = "grafana"

  include {
    github {
      identity_provider_id = cloudflare_access_identity_provider.github.id
      name                 = local.owner
      teams = [
        github_team.grafana_admin_users.name,
        github_team.grafana_editor_users.name,
        github_team.grafana_viewer_users.name,
      ]
    }
  }
  require {
    geo = ["JP"]
  }
}

resource "cloudflare_access_policy" "grafana" {
  application_id = cloudflare_access_application.grafana.id
  zone_id        = data.cloudflare_zone.domain.id
  name           = "grafana"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_access_group.grafana.id]
  }
}
