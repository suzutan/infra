# Actions Runner Controller (ARC) v2

このディレクトリは、GitHub Actions の self-hosted runner を Kubernetes 上で動作させるための Actions Runner Controller (ARC) v2 の設定を管理しています。

## 概要

ARC v2 は公式の Helm chart を使用してデプロイされています：
- Controller: `oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller`
- Runner Scale Set: `oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set`

## ディレクトリ構造

```
actions-runner-controller/
├── namespace.yaml              # ARC システム用の namespace
├── kustomization.yaml          # Controller のデプロイ設定
├── values.yaml                 # Controller の Helm values
├── secret-github-app.yaml      # GitHub App 認証情報（1Password 参照）
├── runners/                    # Runner Scale Set の設定
│   ├── namespace.yaml          # Runner 用の namespace
│   ├── kustomization.yaml      # Runner のデプロイ設定
│   ├── values-standard.yaml    # 標準 runner の設定
│   └── values-docker.yaml      # Docker 対応 runner の設定
└── README.md                   # このファイル
```

## Runner の種類

1. **suzutan-self-hosted** (標準 runner)
   - 最大 5 台まで自動スケーリング
   - 通常のビルドやテストに使用
   - runs-on: `self-hosted`

2. **suzutan-docker** (Docker 対応 runner)
   - 最大 3 台まで自動スケーリング
   - Docker イメージのビルドが可能
   - runs-on: `self-hosted,docker`

## セットアップ手順

### 1. GitHub App の作成

GitHub で新しい App を作成し、以下の権限を設定してください：

**Repository permissions:**
- Actions: Read
- Administration: Read
- Checks: Write
- Deployments: Write
- Metadata: Read
- Pull requests: Write
- Statuses: Write

**Organization permissions:**
- Actions: Read
- Members: Read
- Self-hosted runners: Write

### 2. 1Password への登録

GitHub App の情報を 1Password に登録します：

```json
{
  "github_app_id": "YOUR_APP_ID",
  "github_app_installation_id": "YOUR_INSTALLATION_ID",
  "github_app_private_key": "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
}
```

### 3. secret-github-app.yaml の更新

`secret-github-app.yaml` の `GITHUB_APP_ITEM_ID` を実際の 1Password アイテム ID に置き換えます。

### 4. デプロイ

ArgoCD が自動的に同期してデプロイします。

## 使用方法

GitHub Actions のワークフローで以下のように指定します：

```yaml
# 標準 runner
jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      # ...

# Docker 対応 runner
jobs:
  docker-build:
    runs-on: [self-hosted, docker]
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t myapp .
```

## トラブルシューティング

### Runner が起動しない

1. Controller のログを確認：
   ```bash
   kubectl logs -n actions-runner-system deployment/arc-gha-runner-scale-set-controller
   ```

2. GitHub App の権限を確認

3. 1Password の secret が正しく設定されているか確認

### スケーリングが動作しない

1. GitHub のワークフローが正しい runner ラベルを使用しているか確認
2. Runner Scale Set のログを確認：
   ```bash
   kubectl logs -n suzutan-runners -l app.kubernetes.io/name=gha-runner-scale-set
   ```