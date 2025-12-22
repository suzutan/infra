
resource "cloudflare_dns_record" "smtp" {
  zone_id  = var.cloudflare_dns_zone_id
  name     = var.subdomain
  type     = "MX"
  ttl      = 60
  priority = 1
  content  = "smtp.google.com"
}

resource "cloudflare_dns_record" "spf" {
  zone_id = var.cloudflare_dns_zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = 1
  content = "v=spf1 include:_spf.google.com ~all"
}

resource "cloudflare_dns_record" "verify" {
  zone_id = var.cloudflare_dns_zone_id
  name    = var.subdomain
  type    = "TXT"
  ttl     = 1
  content = var.domain_verify_txt
}

resource "cloudflare_dns_record" "dkim" {
  for_each = var.dkim_records
  zone_id  = var.cloudflare_dns_zone_id
  name     = each.key
  type     = "TXT"
  ttl      = 1
  content  = each.value
}

# # DMARC Record (optional)
resource "cloudflare_dns_record" "dmarc" {
  count   = var.dmarc_record != "" ? 1 : 0
  zone_id = var.cloudflare_dns_zone_id
  name    = var.subdomain == "@" ? "_dmarc" : "_dmarc.${var.subdomain}"
  type    = "TXT"
  ttl     = 1
  content = var.dmarc_record
}
