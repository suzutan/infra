terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.31.0"
    }
  }
  required_version = "1.8.3"

}
