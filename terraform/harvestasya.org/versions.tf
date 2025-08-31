terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.8.4"
    }
  }
  required_version = "1.13.1"

}
