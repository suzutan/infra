resource "cloudflare_dns_record" "keybase_site_verification" {
  zone_id = local.zone_id
  name    = "blog"
  type    = "CNAME"
  ttl     = 1
  proxied = false
  content = "4f5b0a82a8e167b1.vercel-dns-017.com."
}
