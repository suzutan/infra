# Cloudflare Zero Trust Access - Authentik OIDC Provider
resource "cloudflare_zero_trust_access_identity_provider" "authentik" {
  account_id = var.cloudflare_account_id
  name       = "Garthnode Authentik"
  type       = "oidc"

  config = {
    client_id     = var.authentik_client_id
    client_secret = var.authentik_client_secret
    auth_url      = "https://grathnode.harvestasya.org/application/o/authorize/"
    token_url     = "https://grathnode.harvestasya.org/application/o/token/"
    certs_url     = "https://grathnode.harvestasya.org/application/o/cloudflare-access/jwks/"
    scopes        = ["openid", "profile", "email"]
  }
}
