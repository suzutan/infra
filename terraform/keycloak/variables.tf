# Keycloak connection
variable "keycloak_url" {
  description = "Keycloak server URL"
  type        = string
  default     = "https://qualia-admin.harvestasya.org"
}

# Service Account Client Credentials (recommended)
variable "keycloak_client_id" {
  description = "Keycloak service account client ID"
  type        = string
  default     = "terraform"
}

variable "keycloak_client_secret" {
  description = "Keycloak service account client secret"
  type        = string
  sensitive   = true
}

# Cloudflare Access (for GitHub Actions)
variable "cf_access_client_id" {
  description = "Cloudflare Access Service Token Client ID"
  type        = string
  default     = ""
}

variable "cf_access_client_secret" {
  description = "Cloudflare Access Service Token Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

# Realm
variable "realm_name" {
  description = "Keycloak realm name"
  type        = string
  default     = "harvestasya"
}
