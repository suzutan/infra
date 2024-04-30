

# resource "cloudflare_record" "asf" {
#   zone_id = data.cloudflare_zone.domain.id
#   name    = "asf"
#   value   = local.ddns_domain
#   type    = "CNAME"
#   proxied = true
# }
