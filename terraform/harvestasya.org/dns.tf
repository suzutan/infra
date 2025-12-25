# DNS A Record for step-ca ACME (LAN-only access)
resource "cloudflare_dns_record" "acme" {
  zone_id = local.zone_id
  name    = "acme"
  content = "172.20.2.202"
  ttl     = 1
  type    = "A"
  proxied = false # Direct DNS resolution (no Cloudflare proxy)
  comment = "step-ca ACME endpoint (kube-vip)"
}
