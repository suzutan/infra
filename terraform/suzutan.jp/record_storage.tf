
# Google Cloud Storage
resource "cloudflare_record" "storage" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "storage"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  content = "c.storage.googleapis.com"
}
