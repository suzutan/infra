
locals {
  role_mt_dynmap_users = [
    "suzutan",
    "razz0408",
    "nagisberry",
  ]
}

resource "github_team" "mt_dynmap_users" {
  name                      = "mt-dynmap"
  description               = "mt dynmap users"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "mt_dynmap_users" {
  for_each = toset(local.role_mt_dynmap_users)
  team_id  = github_team.mt_dynmap_users.id
  username = each.value
  role     = "maintainer"
}

resource "cloudflare_record" "mt_dynmap" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "mt-dynmap"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_access_application" "mt_dynmap" {
  zone_id                   = data.cloudflare_zone.domain.id
  name                      = "mt dynmap"
  domain                    = cloudflare_record.mt_dynmap.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_access_identity_provider.github.id]
}

resource "cloudflare_access_group" "mt_dynmap" {
  account_id = var.cloudflare_account_id
  name       = "mt_dynmap"

  include {
    github {
      identity_provider_id = cloudflare_access_identity_provider.github.id
      name                 = local.owner
      teams                = [github_team.mt_dynmap_users.name]
    }
  }
  require {
    geo = ["JP"]
  }
}

resource "cloudflare_access_policy" "mt_dynmap" {
  application_id = cloudflare_access_application.mt_dynmap.id
  zone_id        = data.cloudflare_zone.domain.id
  name           = "mt_dynmap"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_access_group.mt_dynmap.id]
  }
}
