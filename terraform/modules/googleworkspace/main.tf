



# Google Workspace
resource "cloudflare_record" "gw_mx_0" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "1"
  value    = "aspmx.l.google.com"
}
resource "cloudflare_record" "gw_mx_1" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "5"
  value    = "alt1.aspmx.l.google.com"
}

resource "cloudflare_record" "gw_mx_2" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "5"
  value    = "alt2.aspmx.l.google.com"
}
resource "cloudflare_record" "gw_mx_3" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "10"
  value    = "alt3.aspmx.l.google.com"
}
resource "cloudflare_record" "gw_mx_4" {
  zone_id  = var.zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "10"
  value    = "alt4.aspmx.l.google.com"
}

resource "cloudflare_record" "gw_txt_spf" {
  zone_id = var.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=spf1 include:_spf.google.com ~all"
}

resource "cloudflare_record" "gw_domain_verify" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = "1"
  value   = var.domain_verify_txt
}
