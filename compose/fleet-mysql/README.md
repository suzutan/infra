# fleet-mysql

Fleet 用の MySQL サーバー。K8s (NFS) 上での MySQL 運用が不安定なため、Proxmox VM 上で Docker Compose で動作させる。

## VM 要件

- **CPU種別: `x86-64-v2` 以上** — MySQL 8.4 の公式イメージが x86-64-v2 命令セットを要求するため、Proxmox のデフォルト (`kvm64`) では起動しない

## セットアップ

```bash
cp .env.example .env
# .env にパスワードを設定 (1Password の fleet/mysql-secret と同じ値)
vim .env

docker compose up -d
```
