# Authentik OIDC Apps Blueprint

This directory contains Authentik blueprints for managing OIDC applications declaratively via GitOps.

## How to Add a New OIDC Application

1. Edit `oidc-apps.yaml` and add your application following this template:

```yaml
# Provider definition
- model: authentik_providers_oauth2.oauth2provider
  id: your-app-provider
  state: present
  identifiers:
    name: Your App Provider
  attrs:
    name: Your App Provider
    client_type: confidential
    client_id: your-app-client-id
    client_secret: !Secret authentik-oidc-secrets:your-app
    authorization_flow: !Find [authentik_flows.flow, [slug, default-provider-authorization-implicit-consent]]
    token_validity: hours=24
    redirect_uris: |
      https://your-app.example.com/oauth2/callback
      http://localhost:3000/oauth2/callback
    property_mappings:
      - !Find [authentik_providers_oauth2.scopemapping, [scope_name, openid]]
      - !Find [authentik_providers_oauth2.scopemapping, [scope_name, email]]
      - !Find [authentik_providers_oauth2.scopemapping, [scope_name, profile]]

# Application definition
- model: authentik_core.application
  id: your-app
  state: present
  identifiers:
    slug: your-app
  attrs:
    name: Your App
    slug: your-app
    provider: !KeyOf your-app-provider
    meta_launch_url: "https://your-app.example.com"
    meta_icon: "https://your-app.example.com/favicon.ico"
    meta_description: "Description of your app"
```

2. Add the client secret to 1Password:
   - The secret should be added to the `authentik-oidc-secrets` item in 1Password
   - Use the key format: `your-app` (matching the blueprint reference)

3. Commit and push your changes. ArgoCD will automatically apply the blueprint.

## Blueprint Structure

Each OIDC application requires two entries:

1. **OAuth2 Provider**: Defines the OIDC/OAuth2 configuration
   - `client_id`: The OAuth client ID
   - `client_secret`: Reference to 1Password secret (!Secret authentik-oidc-secrets:app-name)
   - `redirect_uris`: Allowed redirect URIs (one per line)
   - `property_mappings`: OIDC scopes to include

2. **Application**: The user-facing application entry
   - `slug`: URL-friendly identifier
   - `provider`: Links to the provider using !KeyOf
   - `meta_*`: Display information in Authentik UI

## Secret Management

All client secrets are stored in 1Password under the `authentik-oidc-secrets` item. The blueprint references these secrets using the format:

```yaml
client_secret: !Secret authentik-oidc-secrets:app-name
```

Where `app-name` is the key within the 1Password item.

## Common Configuration Options

### Client Types
- `confidential`: For server-side applications that can securely store secrets
- `public`: For SPAs and mobile apps that cannot store secrets

### Token Validity
- `token_validity`: Access token lifetime (e.g., `hours=24`)
- `refresh_token_validity`: Refresh token lifetime (e.g., `days=30`)
- `access_code_validity`: Authorization code lifetime (e.g., `minutes=1`)

### Subject Mode
- `hashed_user_id`: Returns a hashed user ID (recommended)
- `user_id`: Returns the actual user ID
- `user_uuid`: Returns the user's UUID
- `user_username`: Returns the username

## Troubleshooting

1. **Blueprint not applying**: Check Authentik logs for blueprint errors
2. **Secret not found**: Ensure the secret exists in 1Password with the correct key
3. **Invalid redirect URI**: Make sure all redirect URIs are properly formatted

## References

- [Authentik Blueprints Documentation](https://docs.goauthentik.io/docs/blueprints/)
- [OAuth2 Provider Configuration](https://docs.goauthentik.io/docs/providers/oauth2/)