resource "cloudflare_dns_record" "blog" {
  zone_id = local.zone_id
  name    = "blog"
  type    = "CNAME"
  ttl     = 300
  proxied = false
  content = "4f5b0a82a8e167b1.vercel-dns-017.com."
}
