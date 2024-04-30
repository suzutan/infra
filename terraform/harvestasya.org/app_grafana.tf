resource "cloudflare_record" "grafana" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "grafana"
  value   = local.ddns_domain
  type    = "CNAME"
  proxied = true
}
