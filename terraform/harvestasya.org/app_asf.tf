

# resource "cloudflare_record" "asf" {
#   zone_id = data.cloudflare_zone.domain.id
#   name    = "asf"
#   value   = local.freesia_ddns_domain
#   type    = "CNAME"
#   proxied = true
# }
