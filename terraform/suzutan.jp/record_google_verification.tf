

locals {
  google_site_verifications = [
    "google-site-verification=yCIUWni7A7UrDBJunmCQ905DP_Lb6uogg4d9JIVAiXY",
    "google-site-verification=h-9J9htmIeNeeaLmRKMlJjYulroYelUA8gQcx8wOViU",
  ]
}

resource "cloudflare_dns_record" "google_site_verification" {
  for_each = toset(local.google_site_verifications)
  zone_id  = local.zone_id
  name     = "suzutan.jp"
  type     = "TXT"
  ttl      = "1"
  proxied  = "false"
  content  = each.value
}
