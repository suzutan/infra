# Talos Kubernetes Cluster: symphonic-reactor

## クラスター情報

| 項目 | 値 |
|------|-----|
| クラスター名 | symphonic-reactor |
| VIP (API Server) | 172.20.0.201 |
| Talos バージョン | v1.12.0 |
| Kubernetes バージョン | v1.35.0 |

### ノード構成

| ノード | VMID | IP | 役割 |
|--------|------|-----|------|
| node01 | 201 | 172.20.2.17 | Control Plane |
| node02 | 202 | 172.20.2.18 | Control Plane |
| node03 | 203 | 172.20.2.19 | Control Plane |

### パッチファイル

| ファイル | 説明 |
|---------|------|
| `patch-dns.yaml` | DNS サーバー設定 |
| `patch-ifnames.yaml` | インターフェース名設定 |
| `patch-vip.yaml` | VIP 設定 (Control Plane 用) |

## ISOイメージの準備

https://factory.talos.dev/ から起動するISOイメージを設定する

- Hardware Type: Cloud Server
- Choose Talos Linux Version: v1.12.0
- Cloud: Nocloud (Proxmoxの場合)
- Machine Architecture: amd64
- System Extensions:
  - siderolabs/qemu-guest-agent (ProxmoxでIP確認するため)
  - siderolabs/nfs-utils (nfs-subdir-external-provisionerを使うので)
- Customization:
  - Extra kernel command line arguments: default (未入力)
  - Bootloader: auto
- First Boot
  - ISOのリンクをコピーしてProxmoxに登録する

## 初回セットアップ (1台目の Control Plane)

### VM作成

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

# 起動後、ISOのマウント解除
qm set 201 --delete ide2
qm set 201 --boot order=scsi0
```

### 構成の生成と適用

```bash
export CLUSTER_NAME=symphonic-reactor
export VIP=172.20.0.201
export NODE1_IP=172.20.2.17

# シークレットの生成（初回のみ）
talosctl gen secrets -o secrets.yaml

# 構成の生成（VIP をエンドポイントに指定）
talosctl gen config \
  --with-secrets secrets.yaml \
  --config-patch @patch-dns.yaml \
  --config-patch @patch-ifnames.yaml \
  --config-patch-control-plane @patch-vip.yaml \
  --install-disk /dev/sda \
  $CLUSTER_NAME https://$VIP:6443

# 1台目に構成適用
talosctl apply-config --insecure --nodes $NODE1_IP --file controlplane.yaml

# endpoint設定
talosctl --talosconfig=./talosconfig config endpoints $NODE1_IP

# etcd bootstrap（1台目のみ）
talosctl bootstrap --nodes $NODE1_IP --talosconfig=./talosconfig

# kubeconfig取得
talosctl kubeconfig --nodes $NODE1_IP --talosconfig=./talosconfig

# 健全性確認
talosctl --nodes $NODE1_IP --talosconfig=./talosconfig health
```

## 追加の Control Plane ノード (2台目、3台目)

### VM作成

```bash
# 2台目
qm create 202 \
  --name node02.symphonic-reactor \
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
qm start 202

# 3台目
qm create 203 \
  --name node03.symphonic-reactor \
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
qm start 203
```

### 構成適用

```bash
export NODE2_IP=172.20.2.18
export NODE3_IP=172.20.2.19

# 起動後、ISOのマウント解除
qm set 202 --delete ide2 && qm set 202 --boot order=scsi0
qm set 203 --delete ide2 && qm set 203 --boot order=scsi0

# 2台目に構成適用
talosctl apply-config --insecure --nodes $NODE2_IP --file controlplane.yaml

# 3台目に構成適用
talosctl apply-config --insecure --nodes $NODE3_IP --file controlplane.yaml

# endpoint を全ノードに更新
talosctl --talosconfig=./talosconfig config endpoints $NODE1_IP $NODE2_IP $NODE3_IP

# 健全性確認
talosctl --talosconfig=./talosconfig health
kubectl get nodes
```

## 既存クラスターへの VIP 追加（1台→3台への移行）

既存の単一ノードクラスターに VIP を追加して HA 構成にする場合:

```bash
export NODE1_IP=172.20.2.17

# 1. 既存ノードに VIP 設定を追加
talosctl patch machineconfig -n $NODE1_IP --patch @patch-vip.yaml --talosconfig=./talosconfig

# 2. 構成を再生成（VIP をエンドポイントに）
talosctl gen config \
  --with-secrets secrets.yaml \
  --config-patch @patch-dns.yaml \
  --config-patch @patch-ifnames.yaml \
  --config-patch-control-plane @patch-vip.yaml \
  --install-disk /dev/sda \
  symphonic-reactor https://172.20.0.201:6443

# 3. 追加ノードに適用（上記「追加の Control Plane ノード」セクション参照）
```

## パッチ適用

```bash
talosctl patch machineconfig -n $NODE1_IP --patch @patch-dns.yaml --talosconfig=./talosconfig
talosctl patch machineconfig -n $NODE1_IP --patch @patch-ifnames.yaml --talosconfig=./talosconfig
talosctl patch machineconfig -n $NODE1_IP --patch @patch-vip.yaml --talosconfig=./talosconfig
```

## Talos アップグレード

```bash
talosctl upgrade -n $NODE1_IP --image ghcr.io/siderolabs/installer:v1.12.0 --talosconfig=./talosconfig
```
