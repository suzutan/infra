resource "cloudflare_ruleset" "ingress" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "ingress"
  kind    = "zone"
  phase   = "http_request_origin"

  rules {
    enabled     = true
    description = "map-e napt config"
    action      = "route"
    action_parameters {
      origin {
        port = 17201
      }
    }

    expression = <<-EOT
      (http.host in {
        "${cloudflare_record.argocd.hostname}"
        "${cloudflare_record.asf.hostname}"
        "${cloudflare_record.mt_dynmap.hostname}"
      })
    EOT
  }
}
