terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.40.0"
    }
  }
  required_version = "1.9.5"

}
