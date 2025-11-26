# Cloudflare Zero Trust Access Application for Artonelico (Proxmox VE pve02)

# Cloudflare Access Application
resource "cloudflare_zero_trust_access_application" "artonelico" {
  account_id                = var.cloudflare_account_id
  name                      = "Artonelico (Proxmox VE)"
  domain                    = "artonelico.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.authentik.id]

  policies = [
    {
      decision = "allow"
      include = [
        {
          login_method = {
            id = cloudflare_zero_trust_access_identity_provider.authentik.id
          }
        }
      ]
    }
  ]
}
