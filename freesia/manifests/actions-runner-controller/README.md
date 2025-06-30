# Actions Runner Controller (ARC) v2

このディレクトリは、GitHub Actions Runner Controller (ARC) v2のデプロイメント設定を管理しています。

## 概要

Actions Runner Controller v2は、Kubernetesクラスタ上でGitHub Actionsのself-hosted runnerを動的に管理するためのコントローラーです。

## 構成

### コントローラー

- **Namespace**: `actions-runner-system`
- **Helm Chart**: `gha-runner-scale-set-controller`
- **認証方式**: GitHub App (1Password経由)

### Runner Types

1. **suzutan-self-hosted**: 標準的なrunner
   - 最小: 0台
   - 最大: 5台
   - 用途: 一般的なビルドやテスト

2. **suzutan-docker**: Docker対応runner
   - 最小: 0台
   - 最大: 3台
   - 用途: Dockerビルドが必要なワークフロー

## セットアップ手順

### 1. GitHub Appの作成

1. GitHub.comで新しいGitHub Appを作成
2. 以下の権限を設定:
   - **Repository permissions**:
     - Actions: Read
     - Administration: Read & Write
     - Metadata: Read
   - **Organization permissions** (組織で使用する場合):
     - Self-hosted runners: Read & Write

3. Webhookは無効化

### 2. 1Passwordへの認証情報登録

以下の3つのアイテムを1Passwordに作成:

1. **GITHUB_APP_ID**
   - タイプ: パスワード
   - フィールド名: `app-id`
   - 値: GitHub App ID

2. **GITHUB_APP_INSTALLATION_ID**
   - タイプ: パスワード
   - フィールド名: `installation-id`
   - 値: Installation ID

3. **GITHUB_APP_PRIVATE_KEY**
   - タイプ: パスワード
   - フィールド名: `private-key`
   - 値: Private Key (-----BEGIN RSA PRIVATE KEY-----から-----END RSA PRIVATE KEY-----まで全て)

### 3. OnePasswordItemの更新

各`onepassword-*.yaml`ファイルの`itemPath`を実際の1PasswordアイテムIDに更新:

```yaml
spec:
  itemPath: "vaults/5mixaulvwor6zfvbfmtqlksdy4/items/<実際のアイテムID>"
```

### 4. デプロイ

ArgoCDが自動的に同期してデプロイされます。

## 使用方法

### ワークフローでの指定

GitHub Actionsワークフローで以下のように指定:

```yaml
# 標準runner
runs-on: suzutan-self-hosted

# Docker対応runner
runs-on: suzutan-docker
```

### スケーリング動作

- ジョブがない場合: 0台にスケールダウン
- ジョブが来た場合: 自動的にスケールアップ（最大数まで）
- ジョブ完了後: 自動的にスケールダウン

## トラブルシューティング

### ログの確認

```bash
kubectl logs -n actions-runner-system deployment/actions-runner-controller-gha-rs-controller
```

### Runnerの状態確認

```bash
kubectl get runners -n actions-runner-system
```

## 参考資料

- [Actions Runner Controller Documentation](https://github.com/actions/actions-runner-controller)
- [GitHub App Authentication](https://docs.github.com/en/developers/apps/building-github-apps/authenticating-with-github-apps)