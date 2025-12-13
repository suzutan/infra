# Reusable Access Policies
# 複数のアプリケーションで共有可能なポリシー定義

# Infrastructure Admin Policy - GitHub認証 + 管理者メール
resource "cloudflare_zero_trust_access_policy" "infrastructure_admin" {
  account_id = var.cloudflare_account_id
  name       = "Infrastructure Admin Access"
  decision   = "allow"

  include = [
    {
      login_method = {
        id = cloudflare_zero_trust_access_identity_provider.github.id
      }
    }
  ]

  require = [
    {
      email = {
        email = var.infrastructure_admin_email
      }
    }
  ]
}
