terraform {
  cloud {
    organization = "suzutan"
    workspaces {
      name = "suzutan-jp"
    }
  }
}

locals {
  domain     = "suzutan.jp"
  account_id = "3b433b4bc6b6f9770dbf88886748ec8b"
}


data "cloudflare_zone" "domain" {
  name = local.domain
}