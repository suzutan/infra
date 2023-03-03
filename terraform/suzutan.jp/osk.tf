# IP管理については以下
# https://docs.google.com/spreadsheets/d/1U9ArVNPf-nQ4ayHRI1HYsTG8QVtpbI2KvGX2g2vWmck/edit#gid=1892221022

# osk

resource "cloudflare_record" "osk_nw" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "osk.nw"
  type    = "A"
  value   = "172.20.1.1"
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "rt_osk_nw" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "rt.osk.nw"
  type    = "A"
  value   = "172.20.1.1"
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "silverstone_osk_nw" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "silverstone.osk.nw"
  type    = "A"
  value   = "172.20.1.2"
  proxied = false
  ttl     = 1
}

// mirakc
resource "cloudflare_record" "spica" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "spica"
  type    = "CNAME"
  value   = "edge.osk.nw.suzutan.jp"
  proxied = true
  ttl     = 1
}
// epgstation
resource "cloudflare_record" "atria" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "atria"
  type    = "CNAME"
  value   = "edge.osk.nw.suzutan.jp"
  proxied = true
  ttl     = 1
}
