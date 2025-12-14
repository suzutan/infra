
resource "cloudflare_zero_trust_tunnel_cloudflared" "archia" {
  account_id = var.cloudflare_account_id
  name       = "Archia SSH"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "archia" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.archia.id

  config = {
    ingress = [{
      hostname = "archia.${local.zone_name}"
      service  = "ssh://localhost:22"
      },
      {
        service = "http_status:404"
    }]
  }
}

resource "cloudflare_dns_record" "archia" {
  zone_id = local.zone_id
  name    = "archia"
  ttl     = "1"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.archia.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  comment = "SSH access to Archia"
}

# Access Application
resource "cloudflare_zero_trust_access_application" "archia" {
  account_id                = var.cloudflare_account_id
  name                      = "Archia SSH"
  domain                    = "archia.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.github.id]

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.infrastructure_admin.id
    }
  ]
}

# Outputs
output "archia_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.archia.id
}
