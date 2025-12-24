# Zitadel

Identity Provider and IAM platform for HomeLab.

## 概要

ZitadelはCloudNative設計のIdentity & Access Management (IAM) プラットフォームです。
Authentikからの移行により、軽量化とCNCF標準準拠を実現します。

- **Version**: v4 (Helm Chart 9.13.0)
- **Repository**: https://github.com/zitadel/zitadel
- **Documentation**: https://zitadel.com/docs

## アーキテクチャ

```
User → Google Workspace OAuth2 → Zitadel (Identity Broker)
                                      ↓
                              Projects + Roles
                                      ↓
                         Applications (OIDC/SAML)
                           - ArgoCD
                           - Grafana
                           - Navidrome
                           - etc.
```

## コンポーネント

| コンポーネント | 説明 |
|--------------|------|
| **Zitadel** | IAMコア (1 replica) |
| **PostgreSQL** | CNPG管理 (5Gi storage、認証情報自動生成) |
| **1Password** | Secrets管理 (masterkey) |
| **Traefik** | Ingress (zitadel.harvestasya.org) |

## リソース

- **CPU**: 100m (request) / 500m (limit)
- **Memory**: 256Mi (request) / 512Mi (limit)
- **Storage**: 5Gi (PostgreSQL)

## 初期セットアップ

### 1. 1Password Vaultにシークレット作成

#### Masterkey (必須)

```bash
# Masterkey生成 (32文字)
tr -dc A-Za-z0-9 </dev/urandom | head -c 32

# 1Password Vaultに保存
# Item name: zitadel-masterkey
# Fields:
#   - masterkey: <generated-32-chars>
```

#### Database Credentials (不要)

**CNPG Operatorが自動生成するため、手動作成は不要です。**

CNPG Clusterリソースをデプロイすると、以下のSecretが自動生成されます：
- `zitadel-database-app` (アプリケーション用)
- `zitadel-database-superuser` (管理者用)

Zitadelは `zitadel-database-app` Secretを参照します。

### 2. ArgoCD経由でデプロイ

```bash
# ArgoCD Applicationをpush
git add freesia/manifests/zitadel/
git add freesia/manifests/argocd-apps/zitadel.yaml
git commit -m "feat: add Zitadel IAM platform"
git push

# ArgoCD App Sync (自動)
# または手動同期:
argocd app sync zitadel
```

### 3. 初回アクセス

```bash
# ブラウザでアクセス
open https://zitadel.harvestasya.org

# 初回セットアップ
# 1. Admin accountの作成
# 2. Organizationの作成
```

## Google Workspace連携

### External Identity Provider設定

1. **Google Cloud Platformでアプリ作成**
   - OAuth 2.0 Client作成
   - Authorized redirect URIs: `https://zitadel.harvestasya.org/ui/login/externalidp/callback`

2. **Zitadel Console**
   - Settings → Identity Providers → Add Google
   - Client ID/Secret入力
   - Scopes: `openid`, `profile`, `email`

3. **Login Policy**
   - Allow External Login: ON

## 既存Authentikからの移行

### 移行手順

1. **Zitadelセットアップ** (このREADME参照)
2. **Organizations/Projects設計**
   ```
   Organization: Harvestasya
     Project: infrastructure
       Roles: argocd-admin, monitoring-viewer
       Applications:
         - ArgoCD (OIDC)
         - Grafana (OIDC)
         - Prometheus (OIDC)
     Project: media
       Roles: navidrome-user, filebrowser-admin
       Applications:
         - Navidrome (OIDC)
         - FileBrowser (OIDC)
   ```

3. **OIDC Applications移行**
   - ArgoCD OIDC設定変更
   - Cloudflare Access IdP変更
   - Traefik Forward Auth → oauth2-proxy

4. **並行稼働期間**
   - Authentik + Zitadelを並行稼働
   - アプリごとに順次移行

5. **Authentik廃止**
   - すべてのアプリ移行完了後
   - Authentik namespace削除

## Athenz経験者向けメモ

ZitadelとAthenzの概念マッピング:

| Athenz | Zitadel |
|--------|---------|
| Domain | Organization |
| Service | Application |
| Role | Role |
| Policy | Authorization |
| Resource | Project |

Athenzの `domain:role.resource` → Zitadelの `organization:project.role`

## モニタリング

### Prometheus Metrics

```yaml
# ServiceMonitorが自動作成される
serviceMonitor:
  enabled: true
```

メトリクス: `http://zitadel.zitadel.svc.cluster.local:8080/debug/metrics`

### ログ

```bash
# Zitadel logs
kubectl logs -n zitadel -l app.kubernetes.io/name=zitadel -f

# Database logs
kubectl logs -n zitadel -l cnpg.io/cluster=zitadel-database -f
```

## トラブルシューティング

### Database接続エラー

```bash
# PostgreSQL status確認
kubectl get cluster -n zitadel zitadel-database

# Database接続テスト
kubectl run -n zitadel psql-test --rm -it --image=postgres:16 -- \
  psql -h zitadel-database-rw.zitadel.svc.cluster.local -U zitadel -d zitadel
```

### Masterkey not found

```bash
# 1Password Operator確認
kubectl get onepassworditem -n zitadel

# Secret作成確認
kubectl get secret -n zitadel secret-zitadel-masterkey
```

### Init jobが失敗

```bash
# Setup job logs確認
kubectl logs -n zitadel -l app.kubernetes.io/component=setup

# Job削除して再実行
kubectl delete job -n zitadel -l app.kubernetes.io/component=setup
kubectl rollout restart deployment -n zitadel zitadel
```

## 参考資料

- [Zitadel Documentation](https://zitadel.com/docs)
- [Zitadel Helm Charts](https://github.com/zitadel/zitadel-charts)
- [Configure Google as IdP](https://zitadel.com/docs/guides/integrate/identity-providers/google)
- [ZITADEL Roles and Authorizations](https://zitadel.com/docs/guides/manage/console/roles)
