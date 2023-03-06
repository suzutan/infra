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
