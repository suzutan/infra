#!/bin/bash
eval $(op signin)

cat << EOL > .envrc

export AWS_ACCESS_KEY_ID=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/AWS_SECRET_ACCESS_KEY")
export TF_VAR_cloudflare_api_token=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_cloudflare_api_token")


EOL
