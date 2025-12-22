
module "fastmail" {
  source = "../modules/googleworkspace"

  cloudflare_dns_zone_id = local.zone_id
  subdomain              = "@"
  domain_verify_txt      = "google-site-verification=9BYwdIjwYYDoSqPiprmBU63CkFMHa1573EoaZQCnHUI"
  dkim_records = {
    "google._domainkey" = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmVyzw8a6AUqmkhMDaJ83+qRU6ARZJL7aEyOzFCMvrdqamv0e9f/NqfpajJud6nwYdshLkuJImDurYcoD367flUxNIRLXynLDZ8imQREtGeTZUPEYROZ3Rm6YKJJaw9bvO3c2Us6hpYkqtmw73cI5QBi3ZTNCUUjSIekMAEp/j+k0x0y3/Duc8yKIwxtxIrCChVJJn8KGSN6rYW4k98gGiwIT0auvxSqdSdCmQNDz1E18DimPqPc9WHM0j0QbJknNOKu5OFJbthbQTVyhRHDUp3ToprXBtCLBADmNclN1OIyj4RWf2ASI53UfFPqN4XI/xB1P/0kYnD/RNDBU36TUTQIDAQAB"
  }
  dmarc_record = "v=DMARC1; p=quarantine; rua=mailto:postmaster@harvestasya.org; fo=1"
}
