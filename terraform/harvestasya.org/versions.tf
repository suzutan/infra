terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.41.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.3.0"
    }
  }
  required_version = "1.9.6"

}
