terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.10.1"
    }
  }
  required_version = "1.13.3"

}
