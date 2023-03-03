# terraform

ドメインまわりの管理を行うリポジトリ

## deployment pre-request

terraform plan/apply するのに必要な設定

- `terraform login` で terraform cloud にログインする
- CLOUDFLARE_API_TOKEN
  - 対象ドメインを管理しているアカウントの API TOKEN
  - terraform cloud で設定する
  - <https://dash.cloudflare.com/profile/api-tokens>
