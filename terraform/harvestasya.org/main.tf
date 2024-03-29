terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/harvestasya.org"
    region = "ap-northeast-3"
  }
}

locals {
  owner               = "harvestasya"
  zone_name           = "harvestasya.org"
  freesia_ddns_domain = "ddns.harvestasya.org"
}

provider "github" {
  owner = local.owner
  app_auth {
    id              = var.app_id
    installation_id = var.app_installation_id
    pem_file        = var.app_pem_file
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "github_organization" "main" {
  name = local.owner
}

data "cloudflare_zone" "domain" {
  name = local.zone_name
}
