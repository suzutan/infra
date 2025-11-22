# Tech Stack

## Infrastructure as Code

### Kubernetes
- **Version**: kubectl v1.23.0 (aqua で管理)
- **Kustomize**: v5.7.1
- **Helm**: v3.19.2
- **Distribution**: kubeadm でセットアップされたシングルノードクラスタ
- **Container Runtime**: containerd (systemd cgroup 使用)
- **Pod Network**: 10.244.0.0/16

### GitOps
- **ArgoCD**: クラスタ内デプロイメント自動化
  - 自動プルーニング有効
  - 自動セルフヒール有効
  - プロジェクト: apps

### Terraform
- **Version**: v1.14.0
- **State Backend**: Terraform Cloud
- **Provider**: Cloudflare (DNS 管理)

## ツール管理

### aqua (aqua.yaml)
開発ツールのバージョン管理:
- kubectl v1.23.0
- kustomize v5.7.1
- helm v3.19.2
- terraform v1.14.0

### Taskfile
タスクランナー (Task v3):
- yamlfmt: YAML フォーマットチェック

### Renovate
依存関係の自動更新:
- 自動マージ有効
- Semantic commits 使用

## Kubernetes コンポーネント

### Core Infrastructure
- **cert-manager**: 証明書管理 (Let's Encrypt)
- **traefik**: Ingress Controller (IngressRoute 使用)
- **cloudflare-tunnel-ingress-controller**: Cloudflare Tunnel 経由のアクセス
- **onepassword-operator**: シークレット管理
- **nfs-subdir-external-provisioner**: 永続ボリューム
- **cnpg-operator**: PostgreSQL オペレーター
- **kube-state-metrics**: メトリクス収集

### Monitoring
- **temporis/**: Prometheus/Grafana スタック

### Applications
- immich: 写真管理
- authentik: 認証プラットフォーム
- n8n: ワークフロー自動化
- navidrome: 音楽サーバー
- freshrss: RSS リーダー
- asf: Steam 自動化
- hsr-auto-claimer: ゲーム自動クレーム
- ddns: 動的DNS更新
- echoserver: テスト用エコーサーバー

## フォーマットとリンティング

### YAML
- **yamlfmt**: YAML フォーマッター
  - インデント: 2スペース
  - indentless_arrays: true
  - trim_trailing_whitespace: true
  - eof_newline: true
  - gitignore_excludes: true
