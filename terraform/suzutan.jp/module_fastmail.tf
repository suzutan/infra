
module "fastmail" {
  source = "../modules/fastmail"
  domain = data.cloudflare_zone.domain.name
}
