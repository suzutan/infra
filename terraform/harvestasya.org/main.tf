
locals {
  owner               = "harvestasya"
  zone_name           = "harvestasya.org"
  freesia_ddns_domain = "ddns.harvestasya.org"
}

data "github_organization" "main" {
  name = local.owner
}

data "cloudflare_zone" "domain" {
  name = local.zone_name
}
