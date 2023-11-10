resource "cloudflare_record" "auth" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "auth"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}
