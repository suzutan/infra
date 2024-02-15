terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/suzutan.jp"
    region = "ap-northeast-3"
  }
}

locals {
  domain     = "suzutan.jp"
  account_id = "3b433b4bc6b6f9770dbf88886748ec8b"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "domain" {
  name = local.domain
}
