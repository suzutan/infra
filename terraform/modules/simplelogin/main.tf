



# Google Workspace
resource "cloudflare_record" "mx_0" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "10"
  value    = "mx1.simplelogin.co"
}
resource "cloudflare_record" "mx_1" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "20"
  value    = "mx2.simplelogin.co"
}

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=spf1 include:simplelogin.co ~all"
}

resource "cloudflare_record" "dkim_1" {
  zone_id = var.zone_id
  name    = "dkim03._domainkey"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "dkim03._domainkey.simplelogin.co."
}
resource "cloudflare_record" "dkim_2" {
  zone_id = var.zone_id
  name    = var.subdomain == "@" ? "dkim02._domainkey" : "dkim02._domainkey.${var.subdomain}"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "dkim02._domainkey.simplelogin.co."
}
resource "cloudflare_record" "dkim_3" {
  zone_id = var.zone_id
  name    = var.subdomain == "@" ? "dkim._domainkey" : "dkim._domainkey.${var.subdomain}"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "dkim._domainkey.simplelogin.co."
}

resource "cloudflare_record" "dmarc" {
  zone_id = var.zone_id
  name    = var.subdomain == "@" ? "_dmarc" : "_dmarc.${var.subdomain}"
  type    = "TXT"
  ttl     = "1"
  value   = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"
}


resource "cloudflare_record" "verify_domain" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = "1"
  value   = var.domain_verify_txt
}
