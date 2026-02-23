resource "cloudflare_r2_bucket" "grathnode" {
  account_id = var.cloudflare_account_id
  name       = "harvestasya-grathnode"
  location   = "APAC" # Asia-Pacific
}

resource "cloudflare_r2_custom_domain" "grathnode" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.grathnode.name
  domain      = "grathnode.${local.zone_name}"
  enabled     = true
  zone_id     = local.zone_id
}
