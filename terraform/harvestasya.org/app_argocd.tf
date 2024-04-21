
module "app_argocd" {
  source = "../modules/oauth2-application"
  providers = {
    cloudflare = cloudflare
    authentik  = authentik
  }

  zone_name                        = local.zone_name
  subdomain                        = "argocd"
  ddns_domain                      = local.ddns_domain
  authentik_application_launch_url = "https://argocd.${local.zone_name}"
  authentik_application_oauth2_callback_uris = [
    "https://argocd.${local.zone_name}/api/dex/callback"
  ]

}
