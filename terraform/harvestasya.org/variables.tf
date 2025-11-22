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
