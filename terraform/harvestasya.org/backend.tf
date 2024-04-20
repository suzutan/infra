terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/harvestasya.org"
    region = "ap-northeast-3"
  }
}
