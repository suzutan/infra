

locals {
  google_site_verifications = [
    "google-site-verification=yCIUWni7A7UrDBJunmCQ905DP_Lb6uogg4d9JIVAiXY",
    "google-site-verification=h-9J9htmIeNeeaLmRKMlJjYulroYelUA8gQcx8wOViU",
  ]
}

# hatenablog
resource "cloudflare_record" "blog" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "blog"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "hatenablog.com"
}

# Google Cloud Storage
resource "cloudflare_record" "storage" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "storage"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "c.storage.googleapis.com"
}

# other
resource "cloudflare_record" "google_site_verification" {
  for_each = toset(local.google_site_verifications)
  zone_id  = data.cloudflare_zone.domain.id
  name     = "suzutan.jp"
  type     = "TXT"
  ttl      = "1"
  proxied  = "false"
  value    = each.value
}

resource "cloudflare_record" "keybase_site_verification" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "suzutan.jp"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "keybase-site-verification=fobrj4oPvLgdvilm6f8LaHFKxMVvtwUGaLlZERXyydk"
}
