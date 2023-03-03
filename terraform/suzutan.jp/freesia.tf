
resource "cloudflare_record" "ssh" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "ssh.freesia.suzutan.jp"
  type    = "CNAME"
  ttl     = "1"
  proxied = "false"
  value   = "edge.ssa.nw.suzutan.jp"
}
