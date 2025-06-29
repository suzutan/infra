#!/bin/bash
# Helper script to add a new OIDC application to Authentik blueprints

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required arguments are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <app-name> <client-id> <redirect-uri> [additional-redirect-uris...]"
    echo "Example: $0 myapp myapp-client https://myapp.example.com/callback http://localhost:3000/callback"
    exit 1
fi

APP_NAME=$1
CLIENT_ID=$2
shift 2
REDIRECT_URIS=("$@")

# Convert app name to lowercase for consistency
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

echo -e "${GREEN}Adding OIDC application: ${APP_NAME}${NC}"

# Generate the YAML snippet
cat << EOF

  # ${APP_NAME}
  - model: authentik_providers_oauth2.oauth2provider
    id: ${APP_NAME_LOWER}-provider
    state: present
    identifiers:
      name: ${APP_NAME} Provider
    attrs:
      name: ${APP_NAME} Provider
      client_type: confidential
      client_id: ${CLIENT_ID}
      client_secret: !Secret authentik-oidc-secrets:${APP_NAME_LOWER}
      authorization_flow: !Find [authentik_flows.flow, [slug, default-provider-authorization-implicit-consent]]
      token_validity: hours=24
      access_code_validity: minutes=1
      refresh_token_validity: days=30
      sub_mode: hashed_user_id
      include_claims_in_id_token: true
      issuer_mode: per_provider
      redirect_uris: |
EOF

# Add redirect URIs
for uri in "${REDIRECT_URIS[@]}"; do
    echo "        $uri"
done

cat << EOF
      property_mappings:
        - !Find [authentik_providers_oauth2.scopemapping, [scope_name, openid]]
        - !Find [authentik_providers_oauth2.scopemapping, [scope_name, email]]
        - !Find [authentik_providers_oauth2.scopemapping, [scope_name, profile]]

  - model: authentik_core.application
    id: ${APP_NAME_LOWER}
    state: present
    identifiers:
      slug: ${APP_NAME_LOWER}
    attrs:
      name: ${APP_NAME}
      slug: ${APP_NAME_LOWER}
      provider: !KeyOf ${APP_NAME_LOWER}-provider
      policy_engine_mode: any
      meta_launch_url: "${REDIRECT_URIS[0]%%/*}"
      meta_description: "${APP_NAME} OIDC Application"
EOF

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Add the above YAML to blueprints/oidc-apps.yaml"
echo "2. Add client secret to 1Password:"
echo "   - Item: authentik-oidc-secrets"
echo "   - Field name: ${APP_NAME_LOWER}"
echo "   - Generate a secure secret"
echo "3. Commit and push changes"
echo "4. ArgoCD will automatically apply the blueprint"