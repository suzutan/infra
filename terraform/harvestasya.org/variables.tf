variable "cloudflare_account_id" {
  type        = string
  description = "Account ID of Cloudflare"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
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

# GitHub App for Organization Management
variable "github_app_id" {
  type        = string
  description = "GitHub App ID"
}

variable "github_app_installation_id" {
  type        = string
  description = "GitHub App Installation ID"
}

variable "github_app_pem_file" {
  type        = string
  description = "GitHub App Private Key (PEM)"
  sensitive   = true
}

