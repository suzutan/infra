

resource "cloudflare_dns_record" "bluesky_site_verification" {
  zone_id = local.zone_id
  name    = "_atproto"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  content = "did=did:plc:ovhusurkc5uzc4zdfzeecuza"
}
