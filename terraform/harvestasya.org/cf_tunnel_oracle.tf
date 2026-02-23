# Cloudflare Zero Trust Tunnel for AdGuard Home DoH
# AdGuard Home VM (https://127.0.0.1:443) を oracle.harvestasya.org で外部公開
#
# 認証フロー:
#   /dns-query/* → CF Access: BYPASS (DoH エンドポイント、AdGuard Home ClientID で識別)
#   /* (Web UI)  → CF Access: GitHub infrastructure_admin 認証必須

# Cloudflare Tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "oracle" {
  account_id = var.cloudflare_account_id
  name       = "Oracle DNS"
}

# Tunnel 設定 - oracle.harvestasya.org を AdGuard Home にルーティング
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "oracle" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.oracle.id

  config = {
    ingress = [
      {
        hostname = "oracle.${local.zone_name}"
        service  = "https://127.0.0.1:443"
        origin_request = {
          no_tls_verify = true # AdGuard Home の自己署名証明書を許可
        }
      },
      {
        # Catch-all (required by cloudflared)
        service = "http_status:404"
      }
    ]
  }
}

# DNS CNAME レコード (明示 CNAME はワイルドカード *.harvestasya.org より優先される)
resource "cloudflare_dns_record" "oracle" {
  zone_id = local.zone_id
  name    = "oracle"
  ttl     = 1
  content = "${cloudflare_zero_trust_tunnel_cloudflared.oracle.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  comment = "Cloudflare Tunnel for AdGuard Home DoH (Oracle DNS)"
}

# =============================================================================
# Cloudflare Access Applications
# =============================================================================

# Access Application - Web UI (GitHub 認証必須)
# パス /dns-query 以外の全リクエストに対して GitHub 認証を要求
resource "cloudflare_zero_trust_access_application" "oracle_ui" {
  account_id                = var.cloudflare_account_id
  name                      = "AdGuard Home (Web UI)"
  domain                    = "oracle.${local.zone_name}"
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

# Access Application - DoH エンドポイント (認証バイパス)
# /dns-query パスへのリクエストは認証不要 (AdGuard Home ClientID で識別)
resource "cloudflare_zero_trust_access_application" "oracle_doh" {
  account_id       = var.cloudflare_account_id
  name             = "AdGuard Home (DoH Bypass)"
  domain           = "oracle.${local.zone_name}/dns-query"
  type             = "self_hosted"
  session_duration = "24h"

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.oracle_doh_bypass.id
    }
  ]
}

# Access Policy - DoH エンドポイントバイパス
resource "cloudflare_zero_trust_access_policy" "oracle_doh_bypass" {
  account_id = var.cloudflare_account_id
  name       = "DoH Endpoint Bypass"

  decision = "bypass"

  include = [
    {
      everyone = {}
    }
  ]
}

# =============================================================================
# Outputs
# =============================================================================

output "oracle_tunnel_id" {
  description = "Cloudflare Tunnel ID for AdGuard Home (Oracle DNS)"
  value       = cloudflare_zero_trust_tunnel_cloudflared.oracle.id
}

output "oracle_tunnel_token" {
  description = "Cloudflare Tunnel token for cloudflared setup on AdGuard Home VM"
  value       = cloudflare_zero_trust_tunnel_cloudflared.oracle.tunnel_secret
  sensitive   = true
}
