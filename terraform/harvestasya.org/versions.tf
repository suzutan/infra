terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.1.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.5.0"
    }
  }
  required_version = "1.10.5"

}
