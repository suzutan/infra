# Reusable Access Policies
# 複数のアプリケーションで共有可能なポリシー定義

# Infrastructure Admin Policy - GitHub認証 + harvestasya org admin team
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
      github_organization = {
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.github.id
        name                 = "harvestasya"
        team                 = "admin"
      }
    }
  ]
}
