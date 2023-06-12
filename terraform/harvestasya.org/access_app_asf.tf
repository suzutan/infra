
locals {
  role_asf_users = [
    "suzutan",
  ]
}

resource "github_team" "asf_users" {
  name                      = "asf"
  description               = "asf users"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "asf_users" {
  for_each = toset(local.role_asf_users)
  team_id  = github_team.asf_users.id
  username = each.value
  role     = "maintainer"
}

resource "cloudflare_record" "asf" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "asf"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_access_application" "asf" {
  zone_id                   = data.cloudflare_zone.domain.id
  name                      = "asf"
  domain                    = cloudflare_record.asf.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_access_identity_provider.github.id]
}

resource "cloudflare_access_group" "asf" {
  account_id = var.cloudflare_account_id
  name       = "asf"

  include {
    github {
      identity_provider_id = cloudflare_access_identity_provider.github.id
      name                 = local.owner
      teams                = [github_team.asf_users.name]
    }
  }
  require {
    geo = ["JP"]
  }
}

resource "cloudflare_access_policy" "asf" {
  application_id = cloudflare_access_application.asf.id
  zone_id        = data.cloudflare_zone.domain.id
  name           = "asf"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_access_group.asf.id]
  }
}
