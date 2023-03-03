
variable "zone_id" {
  description = "cloudflare zone id"
  type        = string
}

variable "subdomain" {
  description = "subdomain"
  type        = string
  default     = "@"
}

variable "mx_server" {
  description = "office365 outlook mail server"
  type        = string
  #ex: horoscope-dev.mail.protection.outlook.com
}

variable "domain_verify_txt" {
  description = "office365 domain verification txt"
  type        = string
  #ex: MS=ms49184270
}