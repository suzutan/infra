output "cloudflare_record" {
  value = cloudflare_record.app
}

output "authentik_oauth2_client_id" {
  value = authentik_provider_oauth2.app.client_id
}

output "authentik_oauth2_client_secret" {
  value     = authentik_provider_oauth2.app.client_id
  sensitive = true
}
