data "cloudflare_zone" "app" {
  name = var.zone_name
}

resource "cloudflare_record" "app" {
  zone_id = data.cloudflare_zone.app.id
  name    = var.subdomain
  value   = var.ddns_domain
  type    = "CNAME"
  proxied = true
}

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-explicit-consent"
}

resource "authentik_group" "app" {
  name = "${var.subdomain}-user"
}

data "authentik_scope_mapping" "app" {
  managed_list = var.authentik_application_oauth2_scope_mapping
}

resource "authentik_provider_oauth2" "app" {
  name               = var.subdomain
  client_id          = var.subdomain
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  redirect_uris      = var.authentik_application_oauth2_callback_uris
  property_mappings  = data.authentik_scope_mapping.app.ids
}

# resource "authentik_policy_expression" "app" {
#   name       = var.subdomain
#   expression = "return True"
# }

resource "authentik_policy_binding" "app" {
  target = authentik_application.app.uuid
  # policy = authentik_policy_expression.app.id
  group = authentik_group.app.id
  order = 0
}

resource "authentik_application" "app" {
  name              = var.subdomain
  slug              = var.subdomain
  protocol_provider = authentik_provider_oauth2.app.id
  meta_launch_url   = var.authentik_application_launch_url
  meta_icon         = var.authentik_application_icon
}
