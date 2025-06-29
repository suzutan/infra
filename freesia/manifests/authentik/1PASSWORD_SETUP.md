# 1Password Setup for Authentik OIDC Secrets

This document explains how to configure 1Password for storing OIDC application client secrets.

## Creating the 1Password Item

1. **Create a new item** in 1Password:
   - **Vault**: `k8s` (or your designated Kubernetes vault)
   - **Item Name**: `authentik-oidc-secrets`
   - **Item Type**: Login or Secure Note

2. **Add fields** for each OIDC application:
   - Click "Add more" or "+" to add custom fields
   - Set the field type to "Password" for secure storage
   - Use the following naming convention:

   | Field Name | Description | Example Value |
   |------------|-------------|---------------|
   | `example-app` | Client secret for Example App | `generate-secure-secret-here` |
   | `argocd` | Client secret for ArgoCD | `existing-argocd-secret` |
   | `grafana` | Client secret for Grafana | `generate-secure-secret-here` |

3. **Generate secure secrets**:
   - Use 1Password's password generator
   - Recommended: 32+ characters, alphanumeric
   - Avoid special characters that might cause issues

## How It Works

1. The `OnePasswordItem` resource (`secret-authentik-oidc-secrets.yaml`) references the 1Password item:
   ```yaml
   spec:
     itemPath: vaults/k8s/items/authentik-oidc-secrets
   ```

2. The 1Password Operator creates a Kubernetes Secret with all the fields from the 1Password item

3. Authentik Blueprints reference these secrets using the format:
   ```yaml
   client_secret: !Secret authentik-oidc-secrets:app-name
   ```

## Adding a New OIDC Application

1. **Add to 1Password**:
   - Edit the `authentik-oidc-secrets` item
   - Add a new field with your app name (e.g., `my-new-app`)
   - Generate and save a secure client secret

2. **Update the Blueprint**:
   - Edit `blueprints/oidc-apps.yaml`
   - Add your new application configuration
   - Reference the secret as: `!Secret authentik-oidc-secrets:my-new-app`

3. **Apply Changes**:
   - Commit and push to Git
   - ArgoCD will sync the changes
   - The 1Password Operator will update the secret
   - Authentik will load the new blueprint on next restart

## Security Best Practices

1. **Never commit secrets** to Git - always use 1Password references
2. **Use strong secrets** - minimum 32 characters
3. **Rotate secrets regularly** - update in 1Password and restart Authentik
4. **Limit access** - only grant 1Password access to necessary team members

## Troubleshooting

### Secret not found error
- Verify the field name in 1Password matches the blueprint reference exactly
- Check that the 1Password Operator has synced (check pod logs)

### Invalid secret format
- Ensure no special characters that might break YAML parsing
- Use alphanumeric characters for maximum compatibility

### Blueprint not loading
- Check Authentik worker logs for blueprint errors
- Verify the ConfigMap is mounted correctly
- Ensure blueprint syntax is valid YAML