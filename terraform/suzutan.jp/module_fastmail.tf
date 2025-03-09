
module "fastmail" {
  source = "../modules/fastmail"

  cloudflare_dns_zone_id = local.zone_id
  domain                 = local.zone_name
}
