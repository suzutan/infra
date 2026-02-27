# Google IdP - 基盤層認証用（Keycloak非依存）
# Google Workspace (harvestasya.org) のネイティブアカウントで認証
resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = var.cloudflare_account_id
  name       = "Google (infra admin)"
  type       = "google"

  config = {
    client_id     = var.google_oauth_client_id
    client_secret = var.google_oauth_client_secret
  }
}
