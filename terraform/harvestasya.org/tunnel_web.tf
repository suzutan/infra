# Cloudflare Zero Trust Tunnel for Web traffic (Traefik)
# ワイルドカード方式: 新規IngressRoute追加時にTerraform変更不要

# Cloudflare Tunnelの作成
resource "cloudflare_zero_trust_tunnel_cloudflared" "web_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "harvestasya symphonic-reactor"
}

# Tunnel設定 - すべての *.harvestasya.org をTraefikにルーティング
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "web_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id

  config = {
    ingress = [
      {
        hostname = "*.${local.zone_name}"
        service  = "https://traefik.traefik.svc.cluster.local"
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

# Output: トンネルトークン (Kubernetes cloudflared設定に使用)
output "web_tunnel_token" {
  description = "Cloudflare Tunnel token for cloudflared in Kubernetes"
  value       = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.tunnel_secret
  sensitive   = true
}

# Output: トンネルID
output "web_tunnel_id" {
  description = "Cloudflare Web Tunnel ID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id
}
