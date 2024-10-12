terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.43.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.3.1"
    }
  }
  required_version = "1.9.7"

}
