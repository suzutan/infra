variable "cloudflare_dns_zone_id" {
  description = "Cloudflare Zone ID where DNS records will be created"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for MX records (use @ for root domain)"
  type        = string
  default     = "@"
}

variable "domain_verify_txt" {
  description = "Google Workspace domain verification TXT record value"
  type        = string
}

variable "dkim_records" {
  description = "DKIM TXT records (optional, map of name to value)"
  type        = map(string)
  default     = {}
}

variable "dmarc_record" {
  description = "DMARC policy record value (optional)"
  type        = string
  default     = ""
}
