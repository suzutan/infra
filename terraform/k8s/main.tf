
# data "cloudflare_zone" "domain" {
#   name = local.domain
# }

resource "libvirt_pool" "k8s" {
  name = "k8s"
  type = "dir"
  path = "/vm/k8s"
}

resource "libvirt_network" "host_bridge" {
  name      = "host-bridge"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true

}

resource "libvirt_volume" "base_ubuntu_2204" {
  name   = "ubuntu-22.04.qcow2"
  source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  pool   = libvirt_pool.k8s.name
}

resource "libvirt_volume" "vm" {
  for_each       = { for vm in local.vm_list : vm.name => vm }
  name           = "${each.value.name}.qcow2"
  pool           = libvirt_pool.k8s.name
  base_volume_id = libvirt_volume.base_ubuntu_2204.id
  size           = each.value.disksize
}

resource "libvirt_cloudinit_disk" "vm" {
  for_each  = { for vm in local.vm_list : vm.name => vm }
  name      = "${each.value.name}.iso"
  pool      = libvirt_pool.k8s.name
  user_data = <<-EOT
#cloud-config
chpasswd: {expire: False}
ssh_pwauth: False
hostname: ${each.value.name}.sv.ssa.suzutan.jp
users:
- name: suzutan
  lock_passwd: false
  shell: /bin/bash
  sudo: ALL=(ALL) NOPASSWD:ALL
  uid: 1000
  ssh_authorized_keys:
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAa9HN0/PoPCH3M7RER0nIy3bIZSvExwJJd3w9XNOYZZ
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJ/FDkdanvkVQV+jhIDLxV+aXyq8cmXFG/01+705bhr

EOT

  network_config = <<-EOT
  version: 2
  ethernets:
    interface0:
      match:
        name: en*
      addresses:
        - ${each.value.ip}/24
      gateway4: ${each.value.gateway}
      nameservers:
        search: []
        addresses: [${each.value.default_dns}]
  EOT

}

resource "libvirt_domain" "vm" {
  for_each  = { for vm in local.vm_list : vm.name => vm }
  name      = each.value.name
  memory    = each.value.memory
  vcpu      = each.value.vcpu
  autostart = true
  cloudinit = libvirt_cloudinit_disk.vm[each.key].id
  disk {
    volume_id = libvirt_volume.vm[each.key].id
  }
  network_interface {
    network_id = libvirt_network.host_bridge.id
    hostname   = "${each.value.name}.sv.ssa.suzutan.jp"
    # addresses  = ["${each.value.ip}"]
    bridge = "br0"
  }
  console {
    type        = "pty"
    target_port = "0"
  }
}
