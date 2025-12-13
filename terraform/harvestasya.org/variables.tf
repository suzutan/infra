variable "cloudflare_account_id" {
  type        = string
  description = "Account ID of Cloudflare"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
}

variable "authentik_client_id" {
  type        = string
  description = "Authentik OIDC Client ID for Cloudflare Access"
  sensitive   = true
}

variable "authentik_client_secret" {
  type        = string
  description = "Authentik OIDC Client Secret for Cloudflare Access"
  sensitive   = true
}

# GitHub OAuth for Infrastructure Access
variable "github_oauth_client_id" {
  type        = string
  description = "GitHub OAuth App Client ID for Infrastructure Access"
  sensitive   = true
}

variable "github_oauth_client_secret" {
  type        = string
  description = "GitHub OAuth App Client Secret for Infrastructure Access"
  sensitive   = true
}

variable "infrastructure_admin_email" {
  type        = string
  description = "Email address for infrastructure admin (GitHub account primary email)"
}
