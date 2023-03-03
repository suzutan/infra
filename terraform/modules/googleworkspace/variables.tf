
variable "zone_id" {
  description = "cloudflare zone id"
  type        = string
}

variable "subdomain" {
  description = "subdomain"
  type        = string
  default     = "@"
}


variable "domain_verify_txt" {
  description = "google workspace domain verification txt"
  type        = string

}