resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "*"
  type    = "CNAME"
  value   = "freesia.sv.ssa.suzutan.jp."
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "adguard" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "adguard"
  type    = "A"
  value   = "172.20.0.200"
  proxied = false
  ttl     = 1
}
