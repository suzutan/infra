terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.46.0"
    }
  }
  required_version = "1.9.8"

}
