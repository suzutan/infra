# R2 Bucket for static files (Proxmox app icons, shared files, etc.)
# Custom domain: grathnode.harvestasya.org (inspired by Grathnode from Ar tonelico 3)

resource "cloudflare_r2_bucket" "grathnode" {
  account_id = var.cloudflare_account_id
  name       = "harvestasya-grathnode"
  location   = "APAC" # Asia-Pacific region for better performance
}

# DNS record for custom domain
resource "cloudflare_dns_record" "grathnode" {
  zone_id = local.zone_id
  name    = "grathnode"
  content = "${cloudflare_r2_bucket.grathnode.name}.${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  ttl     = 1
  type    = "CNAME"
  proxied = false # R2 custom domains require non-proxied CNAME
  comment = "Custom domain for R2 bucket (static files)"
}

# Enable public access via custom domain
# Note: Directory listing is disabled by default (not implemented in R2)
# Files are accessible only via direct URL
resource "cloudflare_r2_custom_domain" "grathnode" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.grathnode.name
  domain      = "grathnode.${local.zone_name}"
  enabled     = true
  zone_id     = local.zone_id
}
