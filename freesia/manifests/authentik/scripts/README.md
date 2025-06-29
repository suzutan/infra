# Authentik Helper Scripts

This directory contains helper scripts for managing Authentik OIDC applications.

## add-oidc-app.sh

A helper script to generate YAML configuration for new OIDC applications.

### Usage

First, make the script executable:
```bash
chmod +x add-oidc-app.sh
```

Then run the script with your application details:
```bash
./add-oidc-app.sh <app-name> <client-id> <redirect-uri> [additional-redirect-uris...]
```

### Examples

**Single redirect URI:**
```bash
./add-oidc-app.sh "My App" "myapp-client" "https://myapp.example.com/callback"
```

**Multiple redirect URIs:**
```bash
./add-oidc-app.sh "My App" "myapp-client" \
  "https://myapp.example.com/callback" \
  "http://localhost:3000/callback" \
  "https://staging.myapp.example.com/callback"
```

### Output

The script will output:
1. YAML configuration to add to `blueprints/oidc-apps.yaml`
2. Instructions for adding the client secret to 1Password
3. Next steps for applying the changes

### Notes

- App names are automatically converted to lowercase for slugs and IDs
- The script assumes confidential client type (server-side apps)
- Default token validity: 24 hours (access), 30 days (refresh)
- Default scopes: openid, email, profile