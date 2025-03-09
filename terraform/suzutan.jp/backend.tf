terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/suzutan.jp"
    region = "ap-northeast-3"
  }
}
