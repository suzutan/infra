terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.51.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.5.0"
    }
  }
  required_version = "1.10.5"

}
