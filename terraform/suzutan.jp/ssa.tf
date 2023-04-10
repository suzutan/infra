
resource "cloudflare_record" "ssa_sv_nas" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "nas.sv.ssa"
  type    = "A"
  value   = "172.20.1.3"
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "ssa_cl_nas" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "nas.cl.ssa"
  type    = "A"
  value   = "172.20.0.221"
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "ssa_sv_freesia" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "freesia.sv.ssa"
  type    = "A"
  value   = "172.20.1.4"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "ssa_cl_ap" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "ap.cl.ssa"
  type    = "A"
  value   = "172.20.0.253"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "ssa_cl_qsw" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "qsw.cl.ssa"
  type    = "A"
  value   = "172.20.0.253"
  proxied = false
  ttl     = 1
}
