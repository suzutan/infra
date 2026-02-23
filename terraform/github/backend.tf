terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/github"
    region = "ap-northeast-3"
  }
}
