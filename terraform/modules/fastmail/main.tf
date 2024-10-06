
data "cloudflare_zone" "domain" {
  name = var.domain
}

resource "cloudflare_record" "mx_0" {
  zone_id  = data.cloudflare_zone.domain.id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "10"
  content  = "in1-smtp.messagingengine.com"
}
resource "cloudflare_record" "mx_1" {
  zone_id  = data.cloudflare_zone.domain.id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "20"
  content  = "in2-smtp.messagingengine.com"
}

resource "cloudflare_record" "spf" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.subdomain
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  content = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "cloudflare_record" "dkim_1" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.subdomain == "@" ? "fm1._domainkey" : "fm1._domainkey.${var.subdomain}"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  content = "fm1.${var.subdomain == "@" ? var.domain : "${var.subdomain}.${var.domain}"}.dkim.fmhosted.com"
}
resource "cloudflare_record" "dkim_2" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.subdomain == "@" ? "fm2._domainkey" : "fm2._domainkey.${var.subdomain}"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  content = "fm2.${var.subdomain == "@" ? var.domain : "${var.subdomain}.${var.domain}"}.dkim.fmhosted.com"
}
resource "cloudflare_record" "dkim_3" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.subdomain == "@" ? "fm3._domainkey" : "fm3._domainkey.${var.subdomain}"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  content = "fm3.${var.subdomain == "@" ? var.domain : "${var.subdomain}.${var.domain}"}.dkim.fmhosted.com"
}
