
# module "app_grafana" {
#   source = "../modules/application"
#   providers = {
#     cloudflare = cloudflare
#   }

#   zone_name                           = local.zone_name
#   subdomain                           = "grafana-v3"
#   ddns_domain                         = local.ddns_domain
#   create_authentik_oauth2_application = true
# }
