terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.26.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.1.0"
    }
  }
  required_version = "1.7.4"

}
