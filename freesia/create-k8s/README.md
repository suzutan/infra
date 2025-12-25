# create

https://docs.siderolabs.com/talos/v1.12/getting-started/getting-started に従い構築する

https://factory.talos.dev/ から起動するISOイメージを設定する

- Hardware Type: Cloud Server
- Choose Talos Linux Version: 最新(記述時点は1.12.0)
- Cloud: Nocloud(Proxmoxの場合はこれ)
- Machine Architecture: amd64
- System Extensions:
  - siderolabs/qemu-guest-agent(proxmoxでIP確認するため)
  - siderolabs/nfs-utils(nfs-subdir-external-provisionerを使うので)
- Customization:
  - Extra kernel command line arguments: default(未入力)
  - Bootloader: auto
- First Boot
  - ISOのリンクをコピーしてProxmoxに登録する

## VM起動と設定の流し込み

```bash

qm create 201 \
  --name node01.symphonic-reactor \
  --cores 8 \
  --memory 16384 \
  --net0 virtio,bridge=vnet2 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:32 \
  --ide2 local:iso/talos-v1.12.0-nocloud-amd64.iso,media=cdrom \
  --boot order=ide2 \
  --ostype l26 \
  --cpu host \
  --agent enabled=1
qm start 201
# 起動後

# isoのマウント解除を行う
qm set 201 --delete ide2
qm set 201 --boot order=scsi0

# step5 インストールディスクを確認する
export CONTROL_PLANE_IP=172.20.2.17
talosctl get disks --insecure --nodes $CONTROL_PLANE_IP
# sdaが出力されるはずなのでメモ

# step6 構成の作成
export CLUSTER_NAME=symphonic-reactor
export DISK_NAME=sda
talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 --install-disk /dev/$DISK_NAME

# step7 構成適用
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml

# step8 endpointの設定
talosctl --talosconfig=./talosconfig config endpoints $CONTROL_PLANE_IP

# step9 etcdクラスタのbootstrap
talosctl bootstrap --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig

# step10 kubernetes kubeconfigの取得
talosctl kubeconfig --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig

# step 11 クラスタの健全性を確認
talosctl --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig health
```

最後にcontrol-plane single nodeで活動するのでtaintを外す

```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

```
talosctl patch machineconfig -n $CONTROL_PLANE_IP --patch @patch-dns.yaml --talosconfig=./talosconfig

talosctl patch machineconfig -n $CONTROL_PLANE_IP --patch @patch-ifnames.yaml --talosconfig=./talosconfig

talosctl upgrade -n $CONTROL_PLANE_IP --image ghcr.io/siderolabs/installer:v1.12.0  --talosconfig=./talosconfig

talosctl get links -n 172.20.2.17 --talosconfig=./talosconfig
