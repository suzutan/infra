# Authentik Blueprint OIDC アプリ管理

このディレクトリには、Authentik Blueprintを使用したOIDCアプリケーション管理の設定が含まれています。

## 概要

Authentik Blueprintを使用することで、OIDCアプリケーションの設定をコードとして管理できます。これにより、dexidpのような宣言的な設定管理が可能になります。

## ディレクトリ構造

```
blueprints/
├── README.md          # このファイル
└── oidc-apps.yaml     # OIDCアプリケーション設定
```

## 新しいOIDCアプリの追加方法

### 1. Blueprint設定の編集

`oidc-apps.yaml` に新しいアプリケーションのエントリを追加します：

```yaml
# 新しいアプリケーション
- model: authentik_providers_oauth2.oauth2provider
  id: myapp-provider
  attrs:
    name: My App Provider
    client_id: myapp
    client_secret: !Secret myapp
    client_type: confidential
    authorization_flow: !Find [authentik_flows.flow, [slug, default-provider-authorization-implicit-consent]]
    redirect_uris: |
      https://myapp.example.com/callback
      https://myapp.example.com/auth/callback
    sub_mode: hashed_user_id
    include_claims_in_id_token: true
    issuer_mode: per_provider
    access_code_validity: minutes=1
    access_token_validity: minutes=5
    refresh_token_validity: days=30
- model: authentik_core.application
  id: myapp
  attrs:
    name: My Application
    slug: myapp
    provider: !KeyOf myapp-provider
    meta_launch_url: "https://myapp.example.com"
    meta_description: "My Application Description"
```

### 2. 1Passwordシークレットの追加

1Passwordの`k8s`ボールトに`authentik-oidc-secrets`アイテムを作成し、以下のフィールドを追加：

- フィールド名: `myapp` (client_idと同じ)
- フィールドタイプ: パスワード
- 値: セキュアなランダム文字列を生成

### 3. デプロイ

変更をコミットしてArgoCDに同期させます：

```bash
git add .
git commit -m "feat: add myapp OIDC configuration"
git push
```

## Blueprint設定の詳細

### Provider設定

- `client_type`: `confidential` (サーバーサイドアプリケーション用)
- `authorization_flow`: デフォルトの暗黙的同意フローを使用
- `sub_mode`: `hashed_user_id` (ユーザーIDをハッシュ化)
- `include_claims_in_id_token`: `true` (IDトークンにクレームを含める)
- `issuer_mode`: `per_provider` (プロバイダーごとに発行者を設定)

### トークンの有効期限

- `access_code_validity`: 1分
- `access_token_validity`: 5分
- `refresh_token_validity`: 30日

### スコープマッピング

必要に応じて以下のスコープを追加できます：

```yaml
property_mappings:
  - !Find [authentik_providers_oauth2.scopemapping, [scope_name, openid]]
  - !Find [authentik_providers_oauth2.scopemapping, [scope_name, profile]]
  - !Find [authentik_providers_oauth2.scopemapping, [scope_name, email]]
  - !Find [authentik_providers_oauth2.scopemapping, [scope_name, groups]]
```

## トラブルシューティング

### Blueprintが適用されない場合

1. Authentik UIの Admin Interface > System > Tasks で Blueprint タスクの実行状況を確認
2. ログを確認: `kubectl logs -n authentik deployment/authentik-worker`
3. ConfigMapが正しく生成されているか確認: `kubectl get configmap -n authentik authentik-blueprints`

### シークレットエラー

1. 1Passwordアイテムが正しく設定されているか確認
2. OnePasswordItemリソースのステータスを確認: `kubectl describe onepassworditem -n authentik secret-authentik-oidc-apps`