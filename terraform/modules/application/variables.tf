
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

variable "create_authentik_oauth2_application" {
  type        = bool
  description = "Create Authentik OAuth2 application"
  default     = true
}
