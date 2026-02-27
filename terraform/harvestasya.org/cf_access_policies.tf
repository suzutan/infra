# Reusable Access Policies
# 複数のアプリケーションで共有可能なポリシー定義

# Infrastructure Admin Policy - Google認証 + harvestasya.org ドメイン
# Keycloak非依存: Google Workspace ネイティブアカウントで認証
resource "cloudflare_zero_trust_access_policy" "infrastructure_admin" {
  account_id = var.cloudflare_account_id
  name       = "Infrastructure Admin Access"
  decision   = "allow"

  include = [
    {
      login_method = {
        id = cloudflare_zero_trust_access_identity_provider.google.id
      }
    }
  ]

  require = [
    {
      email_domain = {
        domain = "harvestasya.org"
      }
    }
  ]
}
