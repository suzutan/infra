#!/bin/bash
eval $(op signin)

cat << EOL > .envrc
export AWS_ACCESS_KEY_ID=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/AWS_SECRET_ACCESS_KEY")
export TF_VAR_github_app_id=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_github_app_id")
export TF_VAR_github_app_installation_id=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_github_app_installation_id")
export TF_VAR_github_app_pem_file=$(op read "op://x6jqey4sr626ozkw3x7dhlns4e/h4j4jqjbbfgivrygocq2adndrm/TF_VAR_github_app_pem_file")
EOL
