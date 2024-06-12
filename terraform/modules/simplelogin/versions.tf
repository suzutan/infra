terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.35.0"
    }
  }
  required_version = "1.8.5"

}
