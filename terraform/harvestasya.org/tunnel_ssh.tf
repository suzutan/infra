# SSH Tunnel + Access

# Tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "ssh_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "harvestasya ssh"
}

# Config
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "ssh_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.ssh_tunnel.id

  config = {
    ingress = [{
      hostname = "ssh.${local.zone_name}"
      service  = "ssh://localhost:22"
      },
      {
        service = "http_status:404"
    }]
  }
}

# DNS
resource "cloudflare_dns_record" "ssh_tunnel_cname" {
  zone_id = local.zone_id
  name    = "ssh"
  ttl     = "1"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.ssh_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  comment = "SSH access to HomeLab"
}

# Access Application
resource "cloudflare_zero_trust_access_application" "ssh" {
  account_id                = var.cloudflare_account_id
  name                      = "SSH Access"
  domain                    = "ssh.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.github.id]

  policies = [
    {
      name       = "GitHub Auth + Email"
      precedence = 1
      decision   = "allow"
      include = [
        {
          login_method = {
            id = cloudflare_zero_trust_access_identity_provider.github.id
          }
        }
      ]
      require = [
        {
          email = {
            email = var.infrastructure_admin_email
          }
        }
      ]
    }
  ]
}

# Outputs
output "ssh_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.ssh_tunnel.id
}

output "ssh_hostname" {
  value = "ssh.${local.zone_name}"
}
