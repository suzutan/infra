
locals {
  role_argocd_admin = [
    "suzutan",
  ]
}

resource "github_team" "argocd_admin" {
  name                      = "argocd-admin"
  description               = "adgocd admin access"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "argocd_admin" {
  for_each = toset(local.role_argocd_admin)
  team_id  = github_team.argocd_admin.id
  username = each.value
  role     = "maintainer"
}


resource "cloudflare_record" "argocd" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "argocd"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_access_application" "argocd" {
  zone_id                   = data.cloudflare_zone.domain.id
  name                      = "argocd"
  domain                    = cloudflare_record.argocd.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_access_identity_provider.github.id]
}

resource "cloudflare_access_group" "argocd" {
  account_id = var.cloudflare_account_id
  name       = "argocd"

  include {
    github {
      identity_provider_id = cloudflare_access_identity_provider.github.id
      name                 = local.owner
      teams                = [github_team.argocd_admin.name]
    }
  }
  require {
    geo = ["JP"]
  }
}

resource "cloudflare_access_policy" "argocd" {
  application_id = cloudflare_access_application.argocd.id
  zone_id        = data.cloudflare_zone.domain.id
  name           = "argocd"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_access_group.argocd.id]
  }
}
