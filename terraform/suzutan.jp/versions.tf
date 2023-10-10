terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.16.0"
    }
  }
  required_version = "1.6.1"

}
