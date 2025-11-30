# Cloudflare Zero Trust Tunnel for Web traffic (Traefik)

locals {
  k8s_ingress_rules = [
    "argocd.harvestasya.org",
    "echoserver.harvestasya.org",
    "grathnode.harvestasya.org",
    "asf.harvestasya.org",
    "navidrome.harvestasya.org",
    "navidrome-filebrowser.harvestasya.org",
    "influxdb2.harvestasya.org",
    "grafana.harvestasya.org",
    "prometheus.harvestasya.org",
    "n8n.harvestasya.org",
  ]
}

# Cloudflare Tunnelの作成
resource "cloudflare_zero_trust_tunnel_cloudflared" "web_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "harvestasya symphonic-reactor"
}

# Tunnel設定 - Traefikにルーティング
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "web_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id

  config = {
    ingress = concat([for ingress_rule in local.k8s_ingress_rules : {

      hostname = ingress_rule
      service  = "https://traefik.traefik.svc.cluster.local"
      origin_request = {
        origin_server_name = ingress_rule
        http_host_header   = ingress_rule
        no_tls_verify      = true
      }
      }],
      [{
        service = "http_status:404"
    }])
  }
}

resource "cloudflare_dns_record" "k8s_ingress" {
  for_each = toset(local.k8s_ingress_rules)
  zone_id  = local.zone_id
  name     = each.value
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.web_tunnel.id}.cfargotunnel.com"
  ttl      = 1
  type     = "CNAME"
  proxied  = true
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
