resource "cloudflare_record" "authentik" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "id"
  value   = local.ddns_domain
  type    = "CNAME"
  proxied = true
}

