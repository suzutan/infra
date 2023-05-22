
resource "cloudflare_record" "ssa_sv_nas" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "nas.sv.ssa"
  type    = "A"
  value   = "172.20.0.202"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "ssa_sv_freesia" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "freesia.sv.ssa"
  type    = "A"
  value   = "172.20.0.201"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "ssa_cl_qsw" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "qsw.sv.ssa"
  type    = "A"
  value   = "172.20.0.253"
  proxied = false
  ttl     = 1
}
