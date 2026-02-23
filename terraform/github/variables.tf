# GitHub App authentication
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

variable "github_organization" {
  type        = string
  description = "GitHub Organization name"
  default     = "harvestasya"
}
