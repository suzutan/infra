provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "github" {
  owner = "harvestasya"

  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
}
