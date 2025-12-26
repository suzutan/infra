# Codebase Structure

## ディレクトリ構造

```
/
├── k8s/                    # Kubernetes 関連
│   ├── init/                  # 初期セットアップスクリプト
│   ├── ansible/               # Ansible playbooks
│   ├── manifests/             # Kubernetes manifests
│   │   ├── argocd/           # ArgoCD 本体
│   │   ├── argocd-apps/      # ArgoCD Application 定義
│   │   ├── cert-manager/     # 証明書管理
│   │   ├── traefik/          # Ingress Controller
│   │   ├── onepassword-operator/  # シークレット管理
│   │   ├── cnpg-operator/    # PostgreSQL オペレーター
│   │   ├── kube-state-metrics/  # メトリクス
│   │   ├── nfs-subdir-external-provisioner/  # ストレージ
│   │   ├── cloudflare-tunnel-ingress-controller/  # Cloudflare Tunnel
│   │   ├── temporis/         # Prometheus/Grafana
│   │   ├── immich/           # 写真管理アプリ
│   │   ├── authentik/        # 認証プラットフォーム
│   │   ├── n8n/              # ワークフロー自動化
│   │   ├── navidrome/        # 音楽サーバー
│   │   ├── freshrss/         # RSS リーダー
│   │   ├── asf/              # Steam 自動化
│   │   ├── hsr-auto-claimer/ # ゲーム自動クレーム
│   │   ├── ddns/             # 動的DNS
│   │   └── echoserver/       # テストサーバー
│   ├── taskfile.yaml         # Task 定義
│   └── README.md
│
├── terraform/                 # Terraform 関連
│   ├── modules/              # Terraform モジュール
│   ├── suzutan.jp/           # suzutan.jp ドメイン管理
│   ├── harvestasya.org/      # harvestasya.org ドメイン管理
│   ├── run.sh               # 実行スクリプト
│   └── README.md
│
├── .github/                   # GitHub Actions
├── .claude/                   # Claude Code 設定
├── .serena/                   # Serena MCP 設定
│
├── aqua.yaml                  # 開発ツールバージョン管理
├── taskfile.yaml              # タスク定義
├── .yamlfmt.yaml             # YAML フォーマット設定
├── renovate.json             # Renovate 設定
├── CLAUDE.md                 # Claude AI 向けガイドライン
├── README.md                 # プロジェクト README
└── LICENSE
```

## 主要ディレクトリの説明

### k8s/manifests/
Kubernetes のすべてのマニフェストを管理。各アプリケーションは独立したディレクトリを持ちます。

**典型的なアプリケーション構造:**
```
k8s/manifests/<app-name>/
├── namespace.yaml          # 名前空間定義
├── kustomization.yaml      # Kustomize 設定
├── deployment.yaml         # Deployment
├── service.yaml           # Service
├── configmap.yaml         # ConfigMap
├── secret.yaml            # Secret (1Password Operator 参照)
└── ingressroute.yaml      # IngressRoute (Traefik)
```

### k8s/manifests/argocd-apps/
すべての ArgoCD Application リソースを集約。各アプリケーションの自動デプロイメントを定義します。

**ArgoCD Application の構造:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
  source:
    path: k8s/manifests/<app-name>
    repoURL: https://github.com/suzutan/infra.git
    targetRevision: HEAD
  project: apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### terraform/
Terraform によるクラウドインフラ管理。主に DNS レコードの管理。

**ドメイン別ディレクトリ:**
- `suzutan.jp/`: suzutan.jp ドメインの Terraform 設定
- `harvestasya.org/`: harvestasya.org ドメインの Terraform 設定
- `modules/`: 再利用可能な Terraform モジュール

## 設定ファイル

### aqua.yaml
開発ツールのバージョンを一元管理:
- kubectl
- kustomize
- helm
- terraform

### taskfile.yaml
タスクランナー設定。主に `yamlfmt` タスクを定義。

### .yamlfmt.yaml
YAML フォーマッターの設定:
- 2スペースインデント
- indentless arrays
- trailing whitespace の削除

### renovate.json
依存関係の自動更新設定:
- Docker images
- Helm charts
- Terraform providers
- GitHub Actions

### CLAUDE.md
Claude AI がこのリポジトリで作業する際のガイドライン。
