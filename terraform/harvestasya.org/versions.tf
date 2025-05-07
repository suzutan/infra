terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.4.0"
    }
  }
  required_version = "1.11.4"

}
