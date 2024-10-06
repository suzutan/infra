
resource "cloudflare_record" "blog" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "blog"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  content = "hatenablog.com"
}
