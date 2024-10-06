# GitHub Pages

locals {
  pages_subdomain = [
    "pages",
    "www"
  ]
}


resource "cloudflare_record" "pages" {
  for_each = toset(local.pages_subdomain)
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value
  type     = "CNAME"
  content  = "suzutan.github.io"
  proxied  = true
  ttl      = 1
}
