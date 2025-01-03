terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
  }
  required_version = "1.10.3"

}
