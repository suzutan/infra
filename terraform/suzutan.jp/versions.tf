terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.8.2"
    }
  }
  required_version = "1.12.2"

}
