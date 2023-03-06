terraform {
  cloud {
    organization = "suzutan"
    workspaces {
      name = "harvestasya"
    }
  }
}

locals {
  owner = "harvestasya"
}

provider "github" {
  owner = local.owner
  app_auth {
    id              = var.app_id              # or `GITHUB_APP_ID`
    installation_id = var.app_installation_id # or `GITHUB_APP_INSTALLATION_ID`
    pem_file        = var.app_pem_file        # or `GITHUB_APP_PEM_FILE`
  }
}

data "github_organization" "main" {
  name = local.owner
}
