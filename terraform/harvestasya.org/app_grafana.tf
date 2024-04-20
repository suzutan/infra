

resource "cloudflare_record" "grafana" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "grafana-v3"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}
