

resource "cloudflare_record" "keybase_site_verification" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "suzutan.jp"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "keybase-site-verification=fobrj4oPvLgdvilm6f8LaHFKxMVvtwUGaLlZERXyydk"
}
