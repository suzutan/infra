terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.21.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.44.0"
    }
  }
  required_version = "1.6.6"

}
