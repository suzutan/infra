
locals {
  role_dynmap_users = [
    "suzutan",
    "razz0408",
  ]
  dynmap_domains = [
    "mc-main-dynmap",
    "mc-resource-dynmap",
  ]
}

resource "github_team" "dynmap_users" {
  name                      = "dynmap-users"
  description               = "minecraft dynmap users"
  privacy                   = "secret"
  create_default_maintainer = false
}
resource "github_team_membership" "dynmap_users" {
  for_each = toset(local.role_dynmap_users)
  team_id  = github_team.dynmap_users.id
  username = each.value
  role     = "maintainer"
}


resource "cloudflare_record" "dynmap_users" {
  for_each = toset(local.dynmap_domains)
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value
  value    = local.freesia_ddns_domain
  type     = "CNAME"
  proxied  = true
}

resource "cloudflare_access_application" "dynmap_users" {
  for_each                  = cloudflare_record.dynmap_users
  zone_id                   = data.cloudflare_zone.domain.id
  name                      = "dynmap-users"
  domain                    = each.value.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_access_identity_provider.github.id]
}

resource "cloudflare_access_group" "dynmap_users" {
  account_id = var.cloudflare_account_id
  name       = "dynmap-users"

  include {
    github {
      identity_provider_id = cloudflare_access_identity_provider.github.id
      name                 = local.owner
      teams = [
        github_team.dynmap_users.name,
      ]
    }
  }
  require {
    geo = ["JP"]
  }
}

resource "cloudflare_access_policy" "dynmap_users" {
  for_each       = cloudflare_access_application.dynmap_users
  application_id = each.value.id
  zone_id        = data.cloudflare_zone.domain.id
  name           = "dynmap-users"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_access_group.dynmap_users.id]
  }
}
