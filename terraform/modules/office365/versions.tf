terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.18.0"
    }
  }
  required_version = "1.6.4"

}
