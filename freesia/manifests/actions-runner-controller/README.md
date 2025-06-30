# Actions Runner Controller

このディレクトリには、GitHub Actions の self-hosted runner を Kubernetes 上で実行するための Actions Runner Controller (ARC) の設定が含まれています。

## 概要

Actions Runner Controller v2 を使用して、@suzutan の GitHub リポジトリで self-hosted runner を実行します。

## セットアップ手順

### 1. GitHub App の作成

1. GitHub で新しい GitHub App を作成します（Settings > Developer settings > GitHub Apps）
2. 以下の権限を設定します：
   - Repository permissions:
     - Actions: Read
     - Administration: Read & Write
     - Metadata: Read
   - Organization permissions (組織で使用する場合):
     - Self-hosted runners: Read & Write
3. App を作成後、以下の情報を取得します：
   - App ID
   - Installation ID（App をインストール後）
   - Private Key（.pem ファイルをダウンロード）

### 2. 1Password にシークレットを登録

1Password に以下の項目を含むアイテムを作成します：
- `github_app_id`: GitHub App ID
- `github_app_installation_id`: Installation ID
- `github_app_private_key`: Private Key の内容（.pem ファイルの中身全体）

### 3. secret-github-app.yaml の更新

`secret-github-app.yaml` の `GITHUB_APP_ITEM_ID` を実際の 1Password アイテム ID に置き換えます。

### 4. デプロイ

ArgoCD が自動的に同期して、Actions Runner Controller がデプロイされます。

## 使用方法

### Runner の種類

2種類の runner が設定されています：

1. **suzutan-runners**: 標準的な runner
   - ラベル: `self-hosted`, `Linux`, `X64`, `suzutan-self-hosted`
   - 最小: 0、最大: 5 runner

2. **suzutan-docker-runners**: Docker-in-Docker をサポートする runner
   - ラベル: `self-hosted`, `Linux`, `X64`, `suzutan-docker`
   - 最小: 0、最大: 3 runner
   - Docker ビルドやコンテナ操作が可能

### GitHub Actions での使用

ワークフローで self-hosted runner を使用するには：

```yaml
jobs:
  build:
    runs-on: [self-hosted, suzutan-self-hosted]
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner!"
```

Docker が必要な場合：

```yaml
jobs:
  docker-build:
    runs-on: [self-hosted, suzutan-docker]
    steps:
      - uses: actions/checkout@v4
      - run: docker build .
```

## スケーリング

Runner は自動的にスケールします：
- ジョブがない場合は 0 にスケールダウン
- ジョブがキューに入ると自動的にスケールアップ
- 最大数に達するまでスケール

## トラブルシューティング

### Runner が起動しない場合

1. GitHub App の権限を確認
2. 1Password のシークレットが正しく設定されているか確認
3. controller のログを確認:
   ```bash
   kubectl logs -n actions-runner-controller deployment/actions-runner-controller
   ```

### Runner がジョブを取得しない場合

1. GitHub リポジトリの Settings > Actions > Runners で runner が表示されているか確認
2. ワークフローのラベルが正しいか確認

## 参考リンク

- [Actions Runner Controller Documentation](https://github.com/actions/actions-runner-controller)
- [GitHub Actions Self-hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)