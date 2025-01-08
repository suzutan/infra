terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.50.0"
    }
  }
  required_version = "1.10.3"

}
