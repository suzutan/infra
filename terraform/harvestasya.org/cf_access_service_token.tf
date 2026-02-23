# Service Token for GitHub Actions
# Keycloak Admin API access from CI/CD pipelines

resource "cloudflare_zero_trust_access_service_token" "github_actions" {
  account_id = var.cloudflare_account_id
  name       = "GitHub Actions - Keycloak Terraform"

  # Token duration: 1 year (8760 hours)
  duration = "8760h"
}

# Policy for Service Token access
resource "cloudflare_zero_trust_access_policy" "github_actions_service_token" {
  account_id = var.cloudflare_account_id
  name       = "GitHub Actions Service Token"
  decision   = "non_identity"

  include = [
    {
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.github_actions.id
      }
    }
  ]
}

# Output: Service Token credentials for GitHub Actions secrets
output "github_actions_cf_access_client_id" {
  description = "CF-Access-Client-Id header value for GitHub Actions"
  value       = cloudflare_zero_trust_access_service_token.github_actions.client_id
  sensitive   = true
}

output "github_actions_cf_access_client_secret" {
  description = "CF-Access-Client-Secret header value for GitHub Actions"
  value       = cloudflare_zero_trust_access_service_token.github_actions.client_secret
  sensitive   = true
}
