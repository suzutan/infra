
locals {
  metrics_rules = [
    "grafana.harvestasya.org",
    "prometheus.harvestasya.org",
  ]
}

resource "random_bytes" "metrics" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "metrics" {
  account_id = var.cloudflare_account_id
  name       = "metrics-ingress"
  secret     = random_bytes.metrics.base64
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "metrics" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.metrics.id

  config {
    dynamic "ingress_rule" {
      for_each = toset(local.metrics_rules)
      content {
        hostname = ingress_rule.value
        service  = "https://traefik"
        origin_request {
          origin_server_name = ingress_rule.value
          http_host_header   = ingress_rule.value
          no_tls_verify      = true
        }
      }
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "metrics" {
  for_each = toset(local.metrics_rules)
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.metrics.id}.cfargotunnel.com"
  type     = "CNAME"
  proxied  = true
}
