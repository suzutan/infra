terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.22.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.45.0"
    }
  }
  required_version = "1.7.0"

}
