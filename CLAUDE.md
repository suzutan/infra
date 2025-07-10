# CLAUDE.md

このファイルは、Claude AIがこのリポジトリで作業する際のガイドラインとルールを定義しています。

## リポジトリの概要

このリポジトリは個人のホームサーバー環境のInfrastructure as Code (IaC)を管理しています。

### 主要なコンポーネント

- **Kubernetes**: `freesia/` ディレクトリ配下
  - ArgoCD を使用した GitOps 環境
  - Kustomize による manifest 管理
  - 各種アプリケーションの Kubernetes manifest
  
- **Terraform**: `terraform/` ディレクトリ配下
  - Cloudflare DNS 設定
  - その他のクラウドインフラストラクチャ

## 作業時のルール

### 1. ファイル形式とスタイル

- **YAML ファイル**:
  - インデントは2スペースを使用
  - `yamlfmt` でフォーマットされている必要がある
  - Kubernetes manifest は標準的な記法に従う
  
- **Terraform**:
  - HCL2 形式に従う
  - モジュール化を推奨

### 2. コミットメッセージ

- Conventional Commits 形式を使用
- 例: `feat:`, `fix:`, `chore:`, `docs:` など
- Renovate が管理する依存関係の更新は自動化されている

### 3. 依存関係管理

- **aqua.yaml**: 開発ツールのバージョン管理
  - kubectl, helm, terraform, kustomize など
- **renovate.json**: 依存関係の自動更新設定
  - 自動マージが有効
  - セマンティックコミットを使用

### 4. Kubernetes 作業時の注意点

- 新しいアプリケーションは `freesia/manifests/` 配下に配置
- ArgoCD Application は `freesia/manifests/argocd-apps/` に定義
- Kustomization を使用してマニフェストを構成
- 以下のパターンに従う:
  - `namespace.yaml`: 名前空間の定義
  - `kustomization.yaml`: Kustomize 設定
  - 適切なディレクトリ構造を維持

### 5. セキュリティ

- **シークレット管理**:
  - 1Password Operator を使用
  - 直接的なシークレットのコミットは禁止
  - シークレット名は `secret-` プレフィックスを使用
  
- **証明書管理**:
  - cert-manager を使用
  - Let's Encrypt または自己署名証明書

### 6. ネットワーク

- **Ingress**:
  - Traefik を使用
  - IngressRoute リソースを使用
  
- **DNS**:
  - Cloudflare で管理
  - Terraform で定義

### 7. モニタリング

- Prometheus/Grafana スタック (`temporis/` 配下)
- メトリクスの収集と可視化

## 推奨される作業フロー

1. 変更前に既存のパターンを確認
2. 同様のコンポーネントの実装を参照
3. Kustomize を使用してマニフェストを管理
4. ArgoCD による自動同期を考慮
5. 適切なラベルとアノテーションを使用

## テスト

- `task yamlfmt` で YAML のフォーマットチェック
- Kubernetes manifest は `kubectl --dry-run=client` でバリデーション
- Terraform は `terraform plan` で変更確認

## 禁止事項

- 本番環境のシークレットを直接コミットしない
- 既存の命名規則から逸脱しない
- ArgoCD の自動同期を無効化しない（特別な理由がない限り）
- 未承認のサービスやツールを追加しない

## ディレクトリ構造の維持

現在のディレクトリ構造を維持し、新しいコンポーネントは適切な場所に配置してください。不明な場合は、類似のコンポーネントの配置を参考にしてください。