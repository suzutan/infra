# IP管理については以下
# https://docs.google.com/spreadsheets/d/1U9ArVNPf-nQ4ayHRI1HYsTG8QVtpbI2KvGX2g2vWmck/edit#gid=1892221022

# osk

resource "cloudflare_dns_record" "osk_nw" {
  zone_id = local.zone_id
  name    = "osk.nw"
  type    = "A"
  content = "172.20.1.1"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "rt_osk_nw" {
  zone_id = local.zone_id
  name    = "rt.osk.nw"
  type    = "A"
  content = "172.20.1.1"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "silverstone_osk_nw" {
  zone_id = local.zone_id
  name    = "silverstone.osk.nw"
  type    = "A"
  content = "172.20.1.2"
  proxied = false
  ttl     = 1
}


resource "cloudflare_dns_record" "spica" {
  zone_id = local.zone_id
  name    = "spica"
  type    = "CNAME"
  content = "edge.osk.nw.suzutan.jp"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "atria" {
  zone_id = local.zone_id
  name    = "atria"
  type    = "CNAME"
  content = "edge.osk.nw.suzutan.jp"
  proxied = true
  ttl     = 1
}
