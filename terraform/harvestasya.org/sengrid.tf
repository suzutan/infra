


resource "cloudflare_record" "sendgrid_mail" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "em1456.mail.harvestasya.org"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "u43989729.wl230.sendgrid.net"
}

resource "cloudflare_record" "dkim_1" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "s1._domainkey.mail.harvestasya.org"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "s1.domainkey.u43989729.wl230.sendgrid.net"
}

resource "cloudflare_record" "dkim_2" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "s2._domainkey.mail.harvestasya.org"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "s2.domainkey.u43989729.wl230.sendgrid.net"
}

resource "cloudflare_record" "dmarc" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "_dmarc.mail.harvestasya.org"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=DMARC1; p=none;"
}
