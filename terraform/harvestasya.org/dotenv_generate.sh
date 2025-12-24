#!/bin/bash
eval $(op signin)

cat << EOL > .envrc
export AWS_ACCESS_KEY_ID=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/AWS_SECRET_ACCESS_KEY")
export TF_VAR_cloudflare_account_id=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_cloudflare_account_id")
export TF_VAR_cloudflare_api_token=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_cloudflare_api_token")
export TF_VAR_github_oauth_client_id=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_github_oauth_client_id")
export TF_VAR_github_oauth_client_secret=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_github_oauth_client_secret")
export TF_VAR_infrastructure_admin_email=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_infrastructure_admin_email")
EOL
