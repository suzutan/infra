terraform {
  backend "s3" {
    bucket = "suzutan-infra"
    key    = "terraform/k8s"
    region = "ap-northeast-3"
  }
}
