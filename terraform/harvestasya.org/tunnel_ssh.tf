# Cloudflare Zero Trust Tunnel for SSH access to Proxmox VM

# ランダムなシークレットを生成
resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

# Cloudflare Tunnelの作成
resource "cloudflare_zero_trust_tunnel_cloudflared" "ssh_tunnel" {
  account_id    = var.cloudflare_account_id
  name          = "harvestasya ssh"
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
}

# Tunnel設定
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

# DNS CNAMEレコードの作成
resource "cloudflare_dns_record" "ssh_tunnel_cname" {
  zone_id = local.zone_id
  name    = "ssh"
  ttl     = "1"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.ssh_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  comment = "Cloudflare Tunnel for SSH access to HomeLab"
}

# Output: トンネルトークン (VM側のcloudflared設定に使用)
output "tunnel_secret" {
  description = "Cloudflare Tunnel token for cloudflared installation"
  value       = cloudflare_zero_trust_tunnel_cloudflared.ssh_tunnel.tunnel_secret
  sensitive   = true
}

# Output: トンネルID
output "tunnel_id" {
  description = "Cloudflare Tunnel ID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.ssh_tunnel.id
}

# Output: SSH接続先ホスト名
output "ssh_hostname" {
  description = "SSH hostname to connect through Cloudflare Tunnel"
  value       = "ssh.${local.zone_name}"
}

# Cloudflare Zero Trust Access Application for SSH
resource "cloudflare_zero_trust_access_application" "ssh" {
  account_id                = var.cloudflare_account_id
  name                      = "SSH Access"
  domain                    = "ssh.${local.zone_name}"
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
