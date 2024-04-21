data "cloudflare_zone" "zone" {
  name = var.zone_name
}

resource "cloudflare_record" "domain" {
  zone_id = data.cloudflare_zone.zone.id
  name    = var.subdomain
  value   = var.ddns_domain
  type    = "CNAME"
  proxied = true
}
