
module "app_argocd" {
  source = "../modules/application"
  providers = {
    cloudflare = cloudflare
  }

  zone_name                           = local.zone_name
  subdomain                           = "argocd"
  ddns_domain                         = local.ddns_domain
  create_authentik_oauth2_application = true
}
