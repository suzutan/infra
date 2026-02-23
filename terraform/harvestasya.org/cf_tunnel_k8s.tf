# Cloudflare Zero Trust Tunnel for Web traffic
# - デフォルト: Pomerium Ingress Controller (policy-based access)
# - Traefik直通: immich, keycloak (policy制御なし), couchdb/livesync (Service Token認証)

# Cloudflare Tunnelの作成
resource "cloudflare_zero_trust_tunnel_cloudflared" "web_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "harvestasya k8s"
}

# Tunnel設定
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "web_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id

  config = {
    ingress = [
      # Policy制御なし - Traefik直通
      {
        hostname = "chronicle.${local.zone_name}" # immich
        service  = "https://traefik.traefik.svc.cluster.local"
        origin_request = {
          no_tls_verify = true
        }
      },
      {
        hostname = "accounts.${local.zone_name}" # keycloak public
        service  = "https://traefik.traefik.svc.cluster.local"
        origin_request = {
          no_tls_verify = true
        }
      },
      {
        hostname = "keycloak-admin.${local.zone_name}" # keycloak admin (Cloudflare Access保護)
        service  = "https://traefik.traefik.svc.cluster.local"
        origin_request = {
          no_tls_verify = true
        }
      },
      {
        hostname = "livesync.${local.zone_name}" # couchdb for obsidian livesync
        service  = "https://traefik.traefik.svc.cluster.local"
        origin_request = {
          no_tls_verify = true
        }
      },
      # デフォルト - Pomerium Ingress Controller (policy-based access)
      {
        hostname = "*.${local.zone_name}"
        service  = "https://pomerium-proxy.pomerium.svc.cluster.local"
        origin_request = {
          no_tls_verify = true
        }
      },
      {
        # Catch-all (required by cloudflared)
        service = "http_status:404"
      }
    ]
  }
}

# DNS ワイルドカードCNAMEレコード
resource "cloudflare_dns_record" "web_tunnel_wildcard" {
  zone_id = local.zone_id
  name    = "*"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id}.cfargotunnel.com"
  ttl     = 1
  type    = "CNAME"
  proxied = true
  comment = "Cloudflare Tunnel wildcard for K8s Traefik"
}

# Tunnel Token (v5 では data source 経由で取得)
data "cloudflare_zero_trust_tunnel_cloudflared_token" "web_tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id
}

# Output: トンネルトークン (Kubernetes cloudflared設定に使用)
output "web_tunnel_token" {
  description = "Cloudflare Tunnel token for cloudflared in Kubernetes"
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.web_tunnel.token
  sensitive   = true
}

# Output: トンネルID
output "web_tunnel_id" {
  description = "Cloudflare Web Tunnel ID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id
}

# =============================================================================
# Cloudflare Access Applications (infra-core layer)
# K8s上のインフラ管理系アプリケーションへのGitHub認証
# =============================================================================

# Obsidian LiveSync (CouchDB) - Service Token認証
# Obsidian クライアントは couchDB_CustomHeaders で CF-Access-Client-Id/Secret を送信
resource "cloudflare_zero_trust_access_application" "livesync" {
  account_id                = var.cloudflare_account_id
  name                      = "Obsidian LiveSync (CouchDB)"
  domain                    = "livesync.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false # API アクセスのためリダイレクト無効

  # Cloudflare が CORS preflight (OPTIONS) に応答し、CouchDB の CORS 設定と一致させる
  cors_headers = {
    allowed_origins   = ["app://obsidian.md", "capacitor://localhost", "http://localhost"]
    allowed_methods   = ["GET", "PUT", "POST", "HEAD", "DELETE", "OPTIONS"]
    allowed_headers   = ["accept", "authorization", "content-type", "origin", "referer", "cf-access-client-id", "cf-access-client-secret"]
    allow_credentials = true
    max_age           = 86400
  }

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.obsidian_livesync_service_token.id
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.infrastructure_admin.id
      precedence = 2
    }
  ]
}

# Keycloak Admin Console - GitHub認証必須 + GitHub Actions Service Token
resource "cloudflare_zero_trust_access_application" "keycloak_admin" {
  account_id                = var.cloudflare_account_id
  name                      = "Keycloak Admin Console"
  domain                    = "keycloak-admin.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.github.id]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.infrastructure_admin.id
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.github_actions_service_token.id
      precedence = 2
    }
  ]
}
