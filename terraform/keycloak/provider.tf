provider "keycloak" {
  client_id     = var.keycloak_client_id
  client_secret = var.keycloak_client_secret
  url           = var.keycloak_url
  realm         = var.realm_name

  # Cloudflare Access headers (for GitHub Actions)
  additional_headers = var.cf_access_client_id != "" ? {
    "CF-Access-Client-Id"     = var.cf_access_client_id
    "CF-Access-Client-Secret" = var.cf_access_client_secret
  } : {}
}
