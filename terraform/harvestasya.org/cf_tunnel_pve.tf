resource "cloudflare_zero_trust_tunnel_cloudflared" "harvestasya" {
  account_id = var.cloudflare_account_id
  name       = "Harvestasya"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "harvestasya" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.harvestasya.id

  config = {
    ingress = [
      {
        hostname = "tyria.${local.zone_name}"
        service  = "ssh://localhost:22"
      },
      {
        hostname = "vista.${local.zone_name}"
        service  = "https://localhost:8006"
        origin_request = {
          origin_server_name = "pve02.ssa.suzutan.jp"
        }
      },
      {
        service = "http_status:404" # catch-all
      }
    ]
  }
}

resource "cloudflare_dns_record" "vista" {
  zone_id = local.zone_id
  name    = "vista"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.harvestasya.id}.cfargotunnel.com"
  ttl     = 1
  type    = "CNAME"
  proxied = true
  comment = "Harvestasya Vista (Proxmox VE Web UI)"
}

resource "cloudflare_dns_record" "tyria" {
  zone_id = local.zone_id
  name    = "tyria"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.harvestasya.id}.cfargotunnel.com"
  ttl     = 1
  type    = "CNAME"
  proxied = true
  comment = "Tyria (Proxmox VE SSH)"
}

resource "cloudflare_zero_trust_access_application" "vista" {
  account_id                = var.cloudflare_account_id
  name                      = "Harvestasya Vista (Proxmox VE)"
  domain                    = "vista.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.google.id]

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.infrastructure_admin.id
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "tyria" {
  account_id                = var.cloudflare_account_id
  name                      = "Tyria (Proxmox VE SSH)"
  domain                    = "tyria.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.google.id]

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.infrastructure_admin.id
    }
  ]
}

# Tunnel Token (v5 では data source 経由で取得)
data "cloudflare_zero_trust_tunnel_cloudflared_token" "harvestasya" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.harvestasya.id
}

output "vista_tunnel_id" {
  value       = cloudflare_zero_trust_tunnel_cloudflared.harvestasya.id
  description = "Harvestasya Vista Tunnel ID"
}

output "harvestasya_tunnel_token" {
  description = "Cloudflare Tunnel token for cloudflared on Harvestasya (PVE)"
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.harvestasya.token
  sensitive   = true
}
