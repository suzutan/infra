terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.32.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
  required_version = "1.8.3"
}
