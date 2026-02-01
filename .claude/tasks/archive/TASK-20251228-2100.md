# Current Task

## Metadata
- **Task ID:** TASK-20251228-2100
- **Started:** 2025-12-28 21:00
- **Last Updated:** 2025-12-28 23:50
- **Status:** suspended

## Request
KeycloakをIdPとして構築し、GWSをSAML SPとして連携。X.509クライアント証明書認証を実装して、証明書がインストールされたデバイスのみGWSにアクセス可能にする。

## Objective
1. Keycloakを最上位IdPとして構築
2. GWSをSAML SPとしてKeycloakに連携
3. 各種アプリ（ArgoCD, Grafana等）をKeycloak OIDCに移行
4. X.509クライアント証明書認証を実装
5. Authentikを廃止

## Context
- 既存のAuthentikからKeycloakへの移行
- GWS Context-Aware Accessの代替としてX.509認証を採用予定
- Helm Chart: codecentric/keycloakx v7.1.5
- データベース: CloudNative PostgreSQL

## Plan

### Phase 1: Keycloak基本構築
- [x] Helm Chartの選定（codecentric/keycloakx）
- [x] CNPGでPostgreSQLクラスタ作成
- [x] values.yaml設定（proxy mode, hostname等）
- [x] IngressRoute設定（dual hostname: qualia/qualia-admin）
- [x] 管理コンソールアクセス確認

### Phase 2: GWS SAML連携
- [x] Keycloakでharvestasya realm作成
- [x] SAMLクライアント作成（GWS用）
- [x] NameID Mapper設定（email）
- [x] Client signature required: OFF
- [x] GWS管理コンソールでSSO設定
- [x] 証明書アップロード（Realm Settings > Keys > RS256）
- [x] SSOプロファイル割り当て
- [x] ログインテスト成功

### Phase 3: OIDC連携
- [x] groupsスコープ作成
- [x] Group Membershipマッパー設定
- [x] ArgoCD OIDCクライアント作成
- [x] Grafana OIDCクライアント作成
- [x] profileスコープ割り当て
- [ ] Grafanaログインテスト（user sync failed - 要調査）

### Phase 4: Passkey認証（保留）
- [ ] WebAuthn Passwordless Policy有効化
- [ ] Required Action設定
- [ ] ユーザーPasskey登録テスト

### Phase 5: forward-auth移行（保留）
- [ ] traefik-forward-auth または oauth2-proxy の選定
- [ ] 既存authentik-forward-auth参照の洗い出し
- [ ] Keycloak対応のforward-auth実装
- [ ] 各アプリのIngressRoute更新

### Phase 6: X.509クライアント証明書認証
- [ ] 証明書発行基盤の検討
- [ ] Keycloak X.509認証設定
- [ ] GWSログイン時の証明書要求設定
- [ ] テスト

### Phase 7: Authentik廃止
- [ ] forward-auth移行完了確認
- [ ] authentikマニフェスト削除
- [ ] ArgoCD Application削除
- [ ] ドキュメント更新

## Progress Log

### 2025-12-28 21:00
- Keycloak Helm Chart選定完了（codecentric/keycloakx）
- CNPGでPostgreSQLクラスタ作成

### 2025-12-28 21:30
- values.yaml設定（proxy mode: xforwarded）
- IngressRoute設定（qualia/qualia-admin dual hostname）
- 管理コンソールアクセス成功

### 2025-12-28 22:00
- harvestasya realm作成
- GWS SAMLクライアント作成
- NameID Mapper設定

### 2025-12-28 22:30
- GWS SAML SSO設定完了
- 証明書の不一致を修正（Realm Settings > Keys > RS256から取得）
- GWSログイン成功

### 2025-12-28 23:00
- ArgoCD, Grafana用OIDCクライアント作成
- groupsスコープ・マッパー設定
- Grafanaログインでuser sync failed発生（要調査）

### 2025-12-28 23:30
- 公開パス制限（/realms/, /resources/, /js/のみ）
- ルートパスリダイレクト追加
- forward-auth移行方針検討（保留）

### 2025-12-28 23:50
- ドキュメント作成（docs/KEYCLOAK_SETUP.md）

## Modified Files

| File | Action | Status |
|------|--------|--------|
| k8s/manifests/keycloak/namespace.yaml | Created | Done |
| k8s/manifests/keycloak/cnpg-cluster.yaml | Created | Done |
| k8s/manifests/keycloak/secret-keycloak-admin.yaml | Created | Done |
| k8s/manifests/keycloak/values.yaml | Created | Done |
| k8s/manifests/keycloak/ingressroute.yaml | Created/Modified | Done |
| k8s/manifests/keycloak/middleware.yaml | Created | Done |
| k8s/manifests/keycloak/kustomization.yaml | Created | Done |
| k8s/manifests/argocd-apps/keycloak.yaml | Created | Done |
| k8s/manifests/authentik/ingressroute.yaml | Modified | Done |
| docs/KEYCLOAK_SETUP.md | Created | Done |

## Decisions Made

| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| codecentric/keycloakx | Quarkus版Keycloak対応、アクティブにメンテナンス | bitnami/keycloak |
| CNPG for PostgreSQL | 既存インフラとの統一、運用効率 | Bitnami PostgreSQL |
| Dual hostname | 管理コンソールと公開エンドポイントの分離 | 単一hostname + path制限 |
| forward-auth保留 | traefik-forward-authのメンテナンス状況確認が必要 | oauth2-proxy per app |

## Blockers / Open Questions

- [ ] Grafana user sync failed - 原因調査必要
- [ ] forward-auth: traefik-forward-auth vs oauth2-proxy の選定
- [ ] X.509証明書発行基盤の検討（Step CA? 自己署名?）

## Next Steps

1. Grafana user sync failed の原因調査・解決
2. forward-auth移行方針の決定
3. Passkey認証の設定継続
4. X.509クライアント証明書認証の実装

## Notes

### Keycloak管理コンソールURL
- 公開: https://qualia.harvestasya.org/realms/harvestasya/account/
- 管理: https://qualia-admin.harvestasya.org/admin/harvestasya/console/

### GWS特権管理者
- 特権管理者はSSOリダイレクト対象外（Google仕様）
- ロックアウト防止のための設計

### 証明書の取得場所
- Realm Settings > Keys > RS256 > Certificate
- GWSにアップロードする証明書はここから取得

### authentik参照残存ファイル
- navidrome/ingressroute-*.yaml
- traefik/config/routes/dashboard.yaml
- temporis/prometheus/ingressroute.yaml
- kubevela/ingressroute-velaux.yaml
- asf/application.yaml
- argocd/patch/cm-argocd-cm.yaml
