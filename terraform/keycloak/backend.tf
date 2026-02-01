terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/keycloak"
    region = "ap-northeast-3"
  }
}
