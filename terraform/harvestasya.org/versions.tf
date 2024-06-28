terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.35.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
  }
  required_version = "1.9.0"

}
