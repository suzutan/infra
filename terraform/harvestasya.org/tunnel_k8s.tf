
locals {
  ingress_rules = [
    "argocd.harvestasya.org",
    "echoserver.harvestasya.org",
    "id.harvestasya.org",
    "grafana.harvestasya.org",
    "navidrome.harvestasya.org",
    "navidrome-filebrowser.harvestasya.org",
  ]
}

resource "random_bytes" "k8s_ingress" {
  length = 32
}

resource "cloudflare_tunnel" "k8s_ingress" {
  account_id = var.cloudflare_account_id
  name       = "k8s-ingress"
  secret     = random_bytes.k8s_ingress.base64
}

resource "cloudflare_tunnel_config" "k8s_ingress" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.k8s_ingress.id

  config {
    dynamic "ingress_rule" {
      for_each = toset(local.ingress_rules)
      content {
        hostname = ingress_rule.value
        service  = "https://traefik.traefik.svc.cluster.local"
        origin_request {
          origin_server_name = ingress_rule.value
          http_host_header   = ingress_rule.value
        }
      }
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "k8s_ingress" {
  for_each = toset(local.ingress_rules)
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value
  value    = "${cloudflare_tunnel.k8s_ingress.id}.cfargotunnel.com"
  type     = "CNAME"
  proxied  = true
}
