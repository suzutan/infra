

data "cloudflare_zone" "domain" {
  name = local.zone_name
}
