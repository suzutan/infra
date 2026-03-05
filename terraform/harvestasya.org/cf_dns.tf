# DNS CNAME Record for tikkle (Cloudflare Pages)
resource "cloudflare_dns_record" "tikkle" {
  zone_id = local.zone_id
  name    = "tikkle"
  content = "tikkle-3n7.pages.dev"
  ttl     = 1
  type    = "CNAME"
  proxied = true # Cloudflare proxy enabled
  comment = "tikkle Cloudflare Pages"
}

# Cloudflare Pages custom domain for tikkle
resource "cloudflare_pages_domain" "tikkle" {
  account_id   = var.cloudflare_account_id
  project_name = "tikkle"
  domain       = "tikkle.harvestasya.org"
}

# DNS A Record for step-ca ACME (LAN-only access)
resource "cloudflare_dns_record" "acme" {
  zone_id = local.zone_id
  name    = "acme"
  content = "10.11.0.202" #step-ca svc/step-certificates-acme
  ttl     = 1
  type    = "A"
  proxied = false # Direct DNS resolution (no Cloudflare proxy)
  comment = "step-ca ACME endpoint (kube-vip)"
}
