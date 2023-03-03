



resource "cloudflare_record" "autodiscover" {
  zone_id = var.zone_id
  name    = "autodiscover${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "CNAME"
  value   = "autodiscover.outlook.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "enterpriseenrollment" {
  zone_id = var.zone_id
  name    = "enterpriseenrollment${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "CNAME"
  value   = "enterpriseenrollment.manage.microsoft.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "enterpriseregistration" {
  zone_id = var.zone_id
  name    = "enterpriseregistration${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "CNAME"
  value   = "enterpriseregistration.windows.net"
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "sip" {
  zone_id = var.zone_id
  name    = "sip${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "CNAME"
  value   = "sipdir.online.lync.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "lyncdiscover" {
  zone_id = var.zone_id
  name    = "lyncdiscover${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "CNAME"
  value   = "webdir.online.lync.com"
  proxied = false
  ttl     = 1
}


resource "cloudflare_record" "_sipfederationtls_tcp" {
  zone_id = var.zone_id
  name    = "_sipfederationtls._tcp${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "SRV"

  data {
    service  = "_sipfederationtls"
    proto    = "_tcp"
    name     = "@"
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com"
  }
}
resource "cloudflare_record" "_sip_tls" {
  zone_id = var.zone_id
  name    = "_sip._tls${var.subdomain == "@" ? "" : ".${var.subdomain}"}"
  type    = "SRV"

  data {
    service  = "_sip"
    proto    = "_tls"
    name     = "@"
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com"
  }
}

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=spf1 include:spf.protection.outlook.com ~all"
}

resource "cloudflare_record" "mx" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = 0
  value    = var.mx_server
}
resource "cloudflare_record" "office365_domain_verify" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = "1"
  value   = var.domain_verify_txt
}
