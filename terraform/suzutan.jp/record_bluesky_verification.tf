

resource "cloudflare_record" "bluesky_site_verification" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "_atproto"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "did=did:plc:ovhusurkc5uzc4zdfzeecuza"
}
