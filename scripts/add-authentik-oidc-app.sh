#!/bin/bash
set -e

# 使用方法を表示
usage() {
  echo "Usage: $0 <app-name> <client-id> <redirect-uris>"
  echo "Example: $0 \"My App\" \"myapp\" \"https://myapp.example.com/callback,https://myapp.example.com/auth/callback\""
  exit 1
}

# 引数チェック
if [ "$#" -ne 3 ]; then
  usage
fi

APP_NAME="$1"
CLIENT_ID="$2"
REDIRECT_URIS="$3"
APP_SLUG=$(echo "$CLIENT_ID" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Blueprint YAMLエントリを生成
cat <<EOF

  # ${APP_NAME}
  - model: authentik_providers_oauth2.oauth2provider
    id: ${APP_SLUG}-provider
    attrs:
      name: ${APP_NAME} Provider
      client_id: ${CLIENT_ID}
      client_secret: !Secret ${CLIENT_ID}
      client_type: confidential
      authorization_flow: !Find [authentik_flows.flow, [slug, default-provider-authorization-implicit-consent]]
      redirect_uris: |
$(echo "$REDIRECT_URIS" | tr ',' '\n' | sed 's/^/        /')
      sub_mode: hashed_user_id
      include_claims_in_id_token: true
      issuer_mode: per_provider
      access_code_validity: minutes=1
      access_token_validity: minutes=5
      refresh_token_validity: days=30
  - model: authentik_core.application
    id: ${APP_SLUG}
    attrs:
      name: ${APP_NAME}
      slug: ${APP_SLUG}
      provider: !KeyOf ${APP_SLUG}-provider
      meta_launch_url: "$(echo "$REDIRECT_URIS" | cut -d',' -f1 | sed 's|/callback.*||' | sed 's|/auth.*||')"
      meta_description: "${APP_NAME}"
EOF

echo ""
echo "上記の設定を freesia/manifests/authentik/blueprints/oidc-apps.yaml に追加してください。"
echo ""
echo "また、1Passwordの 'k8s' ボールトの 'authentik-oidc-secrets' アイテムに以下のフィールドを追加してください："
echo "  - フィールド名: ${CLIENT_ID}"
echo "  - タイプ: パスワード"
echo "  - 値: セキュアなランダム文字列を生成"