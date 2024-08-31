
locals {
  storage_ingress_rules = [
    "storage.harvestasya.org",
    "cdn.harvestasya.org",
    "storage-console.harvestasya.org",
  ]
}

resource "random_bytes" "storage_ingress" {
  length = 32
}

resource "cloudflare_tunnel" "storage_ingress" {
  account_id = var.cloudflare_account_id
  name       = "storage-ingress"
  secret     = random_bytes.storage_ingress.base64
}

resource "cloudflare_tunnel_config" "storage_ingress" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.storage_ingress.id

  config {
    dynamic "ingress_rule" {
      for_each = toset(local.storage_ingress_rules)
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

resource "cloudflare_record" "storage_ingress" {
  for_each = toset(local.storage_ingress_rules)
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value
  value    = "${cloudflare_tunnel.storage_ingress.id}.cfargotunnel.com"
  type     = "CNAME"
  proxied  = true
}
