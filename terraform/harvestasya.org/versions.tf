terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.27.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.1"
    }
  }
  required_version = "1.7.5"

}
