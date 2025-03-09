

resource "cloudflare_dns_record" "keybase_site_verification" {
  zone_id = local.zone_id
  name    = "suzutan.jp"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  content = "keybase-site-verification=fobrj4oPvLgdvilm6f8LaHFKxMVvtwUGaLlZERXyydk"
}
