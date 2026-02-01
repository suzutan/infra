# Keycloak Terraform

Keycloak のグループを宣言的に管理するための Terraform 構成。

## 現在のステータス

**保留中**: Keycloak 26.x と terraform-provider-keycloak の互換性問題により、現在動作しません。

- Issue: https://github.com/keycloak/terraform-provider-keycloak/issues/1342
- エラー: `malformed version:` (serverinfo に version 情報が含まれない)

Provider が修正され次第、再度試行可能です。

## GitHub Actions Secrets

**未設定**: 以下の Secrets を GitHub に設定する必要があります。

| Secret Name | 説明 |
|-------------|------|
| `TF_VAR_KEYCLOAK_CLIENT_SECRET` | Keycloak `terraform` client の secret |
| `TF_VAR_CF_ACCESS_CLIENT_ID` | Cloudflare Service Token Client ID |
| `TF_VAR_CF_ACCESS_CLIENT_SECRET` | Cloudflare Service Token Client Secret |

### 値の取得方法

```bash
# Cloudflare Service Token (harvestasya.org apply 後)
cd ../harvestasya.org
terraform output -raw github_actions_cf_access_client_id
terraform output -raw github_actions_cf_access_client_secret

# Keycloak Client Secret
# Keycloak Admin Console → Clients → terraform → Credentials タブ
```

## Keycloak Service Account 設定

1. Clients → Create client
   - Client ID: `terraform`
   - Client authentication: ON
   - Service account roles: ON

2. Service Account Roles タブ
   - Client Roles → `realm-management`
   - `realm-admin` を Assign

3. Credentials タブから Secret をコピー

## ローカル実行

```bash
# .envrc を作成
cat > .envrc << 'EOF'
source ../harvestasya.org/.envrc
export TF_VAR_keycloak_client_secret="<your-client-secret>"
export TF_VAR_cf_access_client_id="<from-terraform-output>"
export TF_VAR_cf_access_client_secret="<from-terraform-output>"
EOF

# 実行
source .envrc
terraform init
terraform plan
```

## 作成されるリソース

- グループ: `/<app>/<role>` 形式 (例: `/grafana/admin`)
- Client Scope: `groups` (OIDC claims 用)

詳細は `docs/permission-models/BEYONDCORP-PERMISSION-MODEL.md` を参照。
