terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.1.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
  required_version = "1.11.0"

}
