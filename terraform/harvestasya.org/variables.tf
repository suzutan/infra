variable "app_id" {
  type        = number
  description = "ID of the GitHub App"
}

variable "app_installation_id" {
  type        = number
  description = "Installation ID of the GitHub App"
}

variable "app_pem_file" {
  type        = string
  description = "Path to the private key file for the GitHub App"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Account ID of Cloudflare"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
}

variable "github_client_id" {
  type        = string
  description = "Client ID of the GitHub OAuth App"
}

variable "github_client_secret" {
  type        = string
  description = "Client secret of the GitHub OAuth App"
}
