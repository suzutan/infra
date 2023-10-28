terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.17.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.41.0"
    }
  }
  required_version = "1.6.2"

}
