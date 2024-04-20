

resource "cloudflare_record" "argocd" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "argocd"
  value   = local.freesia_ddns_domain
  type    = "CNAME"
  proxied = true
}
