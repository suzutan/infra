terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.38.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.3"
    }
  }
  required_version = "1.9.4"

}
