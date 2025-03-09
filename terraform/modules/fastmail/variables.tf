
variable "cloudflare_dns_zone_id" {
  description = "cloudflare_dns_zone_id"
  type        = string
}
variable "domain" {
  description = "domain"
  type        = string
}

variable "subdomain" {
  description = "subdomain"
  type        = string
  default     = "@"
}
