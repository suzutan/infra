locals {
  domain     = "suzutan.jp"
  account_id = "3b433b4bc6b6f9770dbf88886748ec8b"

  vm_list = [
    {
      name        = "k8s-node01",
      vcpu        = 8,
      memory      = 8 * 1024,
      disksize    = 60 * 1024 * 1024 * 1024,
      ip          = "172.20.0.151"
      default_dns = "172.20.0.200"
      gateway     = "172.20.0.1"
    },
    {
      name        = "k8s-node02",
      vcpu        = 8,
      memory      = 8 * 1024,
      disksize    = 60 * 1024 * 1024 * 1024,
      ip          = "172.20.0.152"
      default_dns = "172.20.0.200"
      gateway     = "172.20.0.1"
    },
    {
      name        = "k8s-node03",
      vcpu        = 8,
      memory      = 8 * 1024,
      disksize    = 60 * 1024 * 1024 * 1024,
      ip          = "172.20.0.153"
      default_dns = "172.20.0.200"
      gateway     = "172.20.0.1"
    },
  ]
}