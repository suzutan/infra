# Artonelico (Proxmox VE) - Tunnel + Access
# PVEホスト上のcloudflared経由で接続（k8s非依存）

# Tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "artonelico_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "Artonelico"
}

# Config
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "artonelico_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.artonelico_tunnel.id

  config = {
    ingress = [
      {
        hostname = "artonelico.${local.zone_name}"
        service  = "https://localhost:8006"
        origin_request = {
          no_tls_verify = true # 自己署名証明書
        }
      },
      {
        service = "http_status:404" # catch-all
      }
    ]
  }
}

# DNS (ワイルドカードより優先)
resource "cloudflare_dns_record" "artonelico_tunnel_cname" {
  zone_id = local.zone_id
  name    = "artonelico"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.artonelico_tunnel.id}.cfargotunnel.com"
  ttl     = 1
  type    = "CNAME"
  proxied = true
  comment = "Artonelico (Proxmox VE)"
}

# Access Application
resource "cloudflare_zero_trust_access_application" "artonelico" {
  account_id                = var.cloudflare_account_id
  name                      = "Artonelico (Proxmox VE)"
  domain                    = "artonelico.${local.zone_name}"
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

# Output
output "artonelico_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.artonelico_tunnel.id
}
