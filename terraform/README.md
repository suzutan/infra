# infra

ドメインまわりの管理を行うリポジトリ

## deployment pre-request

terraform plan/apply するのに必要な環境変数

- CLOUDFLARE_API_TOKEN
  - 対象ドメインを管理しているアカウントのメールアドレス
- AWS_ACCESS_KEY_ID
  - terraform backend に利用している AWS S3 のアクセスキー
- AWS_SECRET_ACCESS_KEY
  - terraform backend に利用している AWS S3 のシークレットキー

## deployment

```bash
make plan
make apply
```
