terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.32.0"
    }
  }
  required_version = "1.8.2"

}
