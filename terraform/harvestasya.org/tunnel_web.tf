# Cloudflare Zero Trust Tunnel for Web traffic (Traefik)

# ランダムなシークレットを生成
resource "random_password" "web_tunnel_secret" {
  length  = 64
  special = false
}

# Cloudflare Tunnelの作成
resource "cloudflare_zero_trust_tunnel_cloudflared" "web_tunnel" {
  account_id    = var.cloudflare_account_id
  name          = "harvestasya web"
  tunnel_secret = base64encode(random_password.web_tunnel_secret.result)
}

# Tunnel設定 - Traefikにルーティング
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "web_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id

  config = {
    ingress = [
      {
        # ワイルドカードですべてのリクエストをTraefikに転送
        hostname = "*.${local.zone_name}"
        service  = "https://traefik.traefik.svc.cluster.local:443"
        origin_request = {
          no_tls_verify = true
        }
      },
      {
        # Catch-all
        service = "http_status:404"
      }
    ]
  }
}

# DNS ワイルドカードCNAMEレコードの作成
resource "cloudflare_dns_record" "web_tunnel_wildcard_cname" {
  zone_id = local.zone_id
  name    = "*"
  ttl     = "1"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  comment = "Cloudflare Tunnel wildcard for web traffic"
}

# Output: トンネルトークン (Kubernetes cloudflared設定に使用)
output "web_tunnel_token" {
  description = "Cloudflare Tunnel token for cloudflared in Kubernetes"
  value       = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.tunnel_token
  sensitive   = true
}

# Output: トンネルID
output "web_tunnel_id" {
  description = "Cloudflare Web Tunnel ID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id
}
