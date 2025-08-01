
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
  ]
}


resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s_ingress" {
  account_id = var.cloudflare_account_id
  name       = "k8s-ingress"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "k8s_ingress" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.k8s_ingress.id
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
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_ingress.id}.cfargotunnel.com"
  ttl      = 1
  type     = "CNAME"
  proxied  = true
}
