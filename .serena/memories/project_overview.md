# Project Overview

このリポジトリは個人のホームサーバー環境を管理するInfrastructure as Code (IaC) プロジェクトです。

## プロジェクトの目的

- 自宅サーバー環境のインフラストラクチャをコードとして管理
- GitOps によるデプロイメント自動化
- 宣言的なインフラストラクチャ定義

## 主要コンポーネント

### Kubernetes クラスタ (k8s/)
- ArgoCD による GitOps デプロイメント
- Kustomize によるマニフェスト管理
- シングルノード構成
- 各種アプリケーション (Immich, Authentik, n8n, Navidrome など) をホスト

### Terraform (terraform/)
- Cloudflare DNS レコード管理
- ドメイン: suzutan.jp, harvestasya.org
- Terraform Cloud でステート管理

## デプロイメント戦略

- Kubernetes: ArgoCD が自動的に Git リポジトリを監視し、変更を自動適用
- Terraform: 手動で plan/apply を実行
- 依存関係: Renovate が自動更新し、自動マージを実施
