# k8s

libvirt で k8s つくるやつ

ssh 先で必要な作業

libvirt のインストールと bridge の設定、nat な default net の削除

```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo apt install cloud-image-utils
sudo apt install virtinst
cat << EOL | sudo tee /etc/netplan/00-installer-config.yaml
# This is the network config written by 'suzutan'
network:
  ethernets:
    eno1:
      dhcp4: false
  version: 2
  bridges:
    br0:
      interfaces: [eno1]
      addresses: [172.20.0.201/24]
      gateway4: 172.20.0.1
      nameservers:
        addresses: [172.20.0.200]
      parameters:
        stp: false
      dhcp4: false
      dhcp6: false
EOL

sudo netplan apply
sudo virsh net-list
sudo virsh net-destroy default
sudo virsh net-undefine default
sudo virsh net-list

# security_driverを無効化
# issue ref: https://github.com/dmacvicar/terraform-provider-libvirt/issues/978#issuecomment-1276244924
root@freesia:/vm# cat /etc/libvirt/qemu.conf | grep -i "security_driver ="
#       security_driver = [ "selinux", "apparmor" ]
security_driver = "none"
```

ssh 元で必要な作業(terraform-provider-libvirt の cloudinit 作成で mkisofs コマンドが必要なため)

```bash
sudo apt install genisoimage
```
