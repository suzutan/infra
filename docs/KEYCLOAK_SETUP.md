# Keycloak セットアップガイド

このドキュメントは、Keycloakを再構築する際の手順を記載します。

## 概要

| 項目 | 値 |
|------|-----|
| 名前空間 | keycloak |
| Helm Chart | codecentric/keycloakx v7.1.5 |
| データベース | CloudNative PostgreSQL |
| 公開URL | qualia.harvestasya.org |
| 管理URL | qualia-admin.harvestasya.org |
| Realm | harvestasya |

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                    Keycloak Namespace                        │
│                                                              │
│  ┌─────────────────────┐      ┌─────────────────────────┐   │
│  │   Keycloak          │      │   PostgreSQL (CNPG)     │   │
│  │   (Quarkus)         │──────│   - keycloak-pg         │   │
│  │   - 1 replica       │      │   - 2Gi storage         │   │
│  └─────────────────────┘      └─────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │
         │ Traefik IngressRoute
         ▼
┌─────────────────────────────────────────────────────────────┐
│  qualia.harvestasya.org (公開)                              │
│    - /realms/* (認証エンドポイント)                         │
│    - /resources/* (静的リソース)                            │
│    - /js/* (JavaScript)                                     │
│    - / → /realms/harvestasya/account/ (リダイレクト)        │
│                                                              │
│  qualia-admin.harvestasya.org (管理)                        │
│    - 全パス許可                                             │
└─────────────────────────────────────────────────────────────┘
```

## Kubernetes マニフェスト

マニフェストは `k8s/manifests/keycloak/` に配置。

| ファイル | 用途 |
|---------|------|
| namespace.yaml | 名前空間定義 |
| cnpg-cluster.yaml | PostgreSQLクラスタ |
| secret-keycloak-admin.yaml | 管理者認証情報 (1Password) |
| values.yaml | Helm values |
| ingressroute.yaml | Traefik IngressRoute |
| middleware.yaml | リダイレクトミドルウェア |
| kustomization.yaml | Kustomize設定 |

## Keycloak管理コンソール設定

### 1. Realm作成

1. 管理コンソール（qualia-admin.harvestasya.org）にログイン
2. 左上のドロップダウン > **Create realm**
3. Realm name: `harvestasya`
4. **Create**

### 2. Google Workspace SAML連携

GWSをSAML SPとして設定し、KeycloakをIdPとする。

#### 2.1 Keycloakクライアント作成

1. **Clients** > **Create client**
2. 設定:

| 項目 | 値 |
|------|-----|
| Client type | SAML |
| Client ID | `https://accounts.google.com/samlrp/<GWS_SAML_ID>` |
| Name | Google Workspace |

3. **Settings** タブ:

| 項目 | 値 |
|------|-----|
| Name ID Format | email |
| Force name ID format | ON |
| Sign documents | OFF |
| Sign assertions | OFF |

4. **Keys** タブ:
   - **Client signature required**: **OFF**

5. **Client scopes** > `<client>-dedicated` > **Mappers** > **Add mapper**:

| 項目 | 値 |
|------|-----|
| Mapper type | User Attribute Mapper For NameID |
| Name | email-nameid |
| User Attribute | email |
| Name ID Format | urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress |

#### 2.2 GWS管理コンソール設定

1. **セキュリティ** > **認証** > **サードパーティのIdPによるSSO**
2. **SSOプロファイルを追加**:

| 項目 | 値 |
|------|-----|
| IDP エンティティID | `https://qualia.harvestasya.org/realms/harvestasya` |
| ログインページURL | `https://qualia.harvestasya.org/realms/harvestasya/protocol/saml` |
| ログアウトページURL | `https://qualia.harvestasya.org/realms/harvestasya/protocol/saml` |
| 証明書 | Keycloak Realm Settings > Keys > RS256 > Certificate |

3. **SSOプロファイルの割り当てを管理** でテスト対象の組織単位に割り当て

#### 2.3 証明書の取得

Keycloak管理コンソールで:
1. **Realm Settings** > **Keys** タブ
2. **RS256** 行の **Certificate** ボタンをクリック
3. 表示された証明書をコピーしてGWSにアップロード

### 3. OIDC クライアント設定

#### 3.1 共通設定テンプレート

1. **Clients** > **Create client**
2. 設定:

| 項目 | 値 |
|------|-----|
| Client type | OpenID Connect |
| Client ID | `<app-name>` |
| Client authentication | ON |
| Authentication flow | Standard flow のみ |

3. **Access settings**:

| 項目 | 値 |
|------|-----|
| Root URL | `https://<app>.harvestasya.org` |
| Valid redirect URIs | `https://<app>.harvestasya.org/<callback-path>` |
| Web origins | `https://<app>.harvestasya.org` |

#### 3.2 groups スコープ作成（初回のみ）

1. **Client scopes** > **Create client scope**
2. 設定:

| 項目 | 値 |
|------|-----|
| Name | groups |
| Protocol | OpenID Connect |
| Include in token scope | ON |

3. **Mappers** > **Add mapper** > **By configuration** > **Group Membership**:

| 項目 | 値 |
|------|-----|
| Name | groups |
| Token Claim Name | groups |
| Full group path | OFF |
| Add to ID token | ON |
| Add to access token | ON |
| Add to userinfo | ON |
| Add to token introspection | ON |

#### 3.3 ArgoCD用クライアント

| 項目 | 値 |
|------|-----|
| Client ID | argocd |
| Valid redirect URIs | `https://argocd.harvestasya.org/auth/callback` |
| Client scopes | openid, profile, email, groups (Optional) |

ArgoCD側設定 (`argocd-cm`):
```yaml
oidc.config: |
  name: Keycloak
  issuer: https://qualia.harvestasya.org/realms/harvestasya
  clientID: argocd
  clientSecret: $oidc.keycloak.clientSecret
  requestedScopes:
    - openid
    - profile
    - email
```

#### 3.4 Grafana用クライアント

| 項目 | 値 |
|------|-----|
| Client ID | grafana |
| Valid redirect URIs | `https://grafana.harvestasya.org/login/generic_oauth` |
| Client scopes | openid, profile, email, groups, offline_access (Optional) |

Grafana側設定 (`grafana.ini`):
```ini
[auth.generic_oauth]
enabled = true
name = Keycloak
scopes = openid profile email groups offline_access
auth_url = https://qualia.harvestasya.org/realms/harvestasya/protocol/openid-connect/auth
token_url = https://qualia.harvestasya.org/realms/harvestasya/protocol/openid-connect/token
api_url = https://qualia.harvestasya.org/realms/harvestasya/protocol/openid-connect/userinfo
role_attribute_path = contains(groups[*], 'grafana.admin') && 'Admin' || contains(groups[*], 'grafana.editor') && 'Editor' || 'Viewer'
```

### 4. グループ設定

1. **Groups** > **Create group**
2. RBACモデルに基づくグループを作成:
   ```
   /<app>/<role>  →  <app>.<role>

   例:
   /argocd/admin   → argocd.admin
   /grafana/admin  → grafana.admin
   /grafana/editor → grafana.editor
   /grafana/viewer → grafana.viewer
   ```
   詳細は `docs/permission-models/BEYONDCORP-PERMISSION-MODEL.md` を参照

3. **Users** > ユーザー選択 > **Groups** タブでグループを割り当て

### 5. ユーザー作成

1. **Users** > **Add user**
2. 必須項目:
   - Username
   - Email
   - Email verified: ON
   - First name, Last name

3. **Credentials** タブでパスワード設定

## トラブルシューティング

### GWS SAML: 「クライアントが見つかりません」

- Keycloakクライアントが正しいRealm（harvestasya）に作成されているか確認
- Client IDがGWSのSAML IDと一致しているか確認

### GWS SAML: 「ドメイン管理者にお問い合わせください」

- 証明書がKeycloak（Realm Settings > Keys > RS256）とGWSで一致しているか確認
- GWSのSSOプロファイルが対象ユーザーの組織単位に割り当てられているか確認

### OIDC: 「Invalid scopes」

- 要求されているスコープ（groups, offline_access等）がクライアントに割り当てられているか確認
- **Clients** > クライアント > **Client scopes** タブで割り当て状況を確認

### OIDC: 「User sync failed」

- groupsマッパーが正しく設定されているか確認
- ユーザーが必要なグループに所属しているか確認

## 関連ドキュメント

- [Keycloak公式ドキュメント](https://www.keycloak.org/documentation)
- [codecentric/keycloakx Helm Chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx)
- [Google Workspace SAML SSO](https://support.google.com/a/answer/12032922)
