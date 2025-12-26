# Code Style and Conventions

## YAML ファイル

### インデント
- **2スペース** を使用
- タブは使用しない

### yamlfmt 設定
- `retain_line_breaks`: true
- `indentless_arrays`: true (配列はインデントしない)
- `trim_trailing_whitespace`: true
- `eof_newline`: true (ファイル末尾に改行)

### Kubernetes Manifest
- 標準的な Kubernetes リソース定義に従う
- Kustomize による構成管理
- ArgoCD Application は `argocd` namespace に配置

## Terraform

### HCL2 形式
- モジュール化を推奨
- リソースは論理的にグループ化

## Git コミットメッセージ

### Conventional Commits 形式
```
<type>: <description>

<optional body>
```

### Type の種類
- `feat:` 新機能
- `fix:` バグ修正
- `chore:` 雑務、メンテナンス
- `docs:` ドキュメント
- `refactor:` リファクタリング
- `test:` テスト

### 例
- `feat: add new application manifest for n8n`
- `fix: correct ingress route for immich`
- `chore: update terraform providers`
- `chore(deps): update helm release authentik to v2025.10.2`

## ディレクトリ構造の規則

### Kubernetes アプリケーション (k8s/manifests/)
```
k8s/manifests/<app-name>/
├── namespace.yaml          # 名前空間定義
├── kustomization.yaml      # Kustomize 設定
├── deployment.yaml         # デプロイメント
├── service.yaml           # サービス
├── ingress.yaml           # Ingress/IngressRoute
└── ...                    # その他のリソース
```

### ArgoCD Application (k8s/manifests/argocd-apps/)
- アプリケーション定義は個別のファイルとして作成
- ファイル名: `<app-name>.yaml`
- kustomization.yaml でまとめる

## 命名規則

### Kubernetes リソース
- 小文字とハイフンを使用
- 例: `my-app`, `postgres-cluster`, `traefik-ingress`

### Secrets
- プレフィックス: `secret-`
- 例: `secret-database-credentials`
- 1Password Operator によって管理

### Labels
- `app.kubernetes.io/name`: アプリケーション名
- `app.kubernetes.io/instance`: インスタンス名
- `app.kubernetes.io/component`: コンポーネント

## セキュリティ規則

### 禁止事項
- **シークレットの直接コミット禁止**
- プレーンテキストのパスワード、トークン、API キーを含めない
- 1Password Operator を使用してシークレットを管理

### 証明書
- cert-manager を使用
- Let's Encrypt または自己署名証明書

## ネットワーク

### Ingress
- Traefik を使用
- `IngressRoute` CRD を使用
- `Ingress` リソースは使用しない

### DNS
- Cloudflare で管理
- Terraform で定義
