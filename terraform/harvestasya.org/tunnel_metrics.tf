
locals {
  metrics_rules = [
    "grafana.harvestasya.org",
    "prometheus.harvestasya.org",
  ]
}


resource "cloudflare_zero_trust_tunnel_cloudflared" "metrics" {
  account_id = var.cloudflare_account_id
  name       = "metrics-ingress"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "metrics" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.metrics.id

  config = {
    ingress = concat([for ingress_rule in local.metrics_rules : {

      hostname = ingress_rule
      service  = "https://traefik"
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

resource "cloudflare_dns_record" "metrics" {
  for_each = toset(local.metrics_rules)
  zone_id  = local.zone_id
  name     = each.value
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.metrics.id}.cfargotunnel.com"
  ttl      = 1
  type     = "CNAME"
  proxied  = true
}
