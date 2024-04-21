
variable "zone_name" {
  type        = string
  description = "zone name"
}

variable "subdomain" {
  type        = string
  description = "subdomain name"
}

variable "ddns_domain" {
  type        = string
  description = "DDNS domain name"
}

variable "authentik_application_launch_url" {
  type        = string
  description = "Application launch url"
  default     = null
}

variable "authentik_application_icon" {
  type        = string
  description = "Application icon"
  default     = null
}

variable "authentik_application_oauth2_callback_uris" {
  type        = list(string)
  description = "oauth2 application callback urls"
  default     = null
}
variable "authentik_application_oauth2_scope_mapping" {
  type        = list(string)
  description = "oauth2 application scope"
  default = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
  ]
}
