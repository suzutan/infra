terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.25.0"
    }
  }
  required_version = "1.7.4"

}
