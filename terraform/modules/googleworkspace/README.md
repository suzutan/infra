# Google Workspace DNS Module

このモジュールは、Google Workspace用のDNSレコードをCloudflareに作成します。

## 機能

- Google Workspace MXレコード（レガシー5レコード形式）
- SPFレコード（オプション）
- ドメイン検証用TXTレコード
- DKIMレコード（オプション）
- DMARCレコード（オプション）

## 使用方法

### 基本的な使用例

```hcl
module "googleworkspace" {
  source = "./modules/googleworkspace"

  cloudflare_dns_zone_id = cloudflare_zone.example.id
  subdomain              = "@"
  domain_verify_txt      = "google-site-verification=xxxxxxxxxx"
}
```

### DKIM/DMARCを含む完全な例

```hcl
module "googleworkspace" {
  source = "./modules/googleworkspace"

  cloudflare_dns_zone_id = cloudflare_zone.example.id
  subdomain              = "@"
  domain_verify_txt      = "google-site-verification=xxxxxxxxxx"

  # オプション: TTLをカスタマイズ（デフォルト: 3600秒）
  ttl = 1800

  # オプション: DKIMレコード
  dkim_records = {
    "google._domainkey" = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA..."
  }

  # オプション: DMARCレコード
  dmarc_record = "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"
}
```

### サブドメインでの使用例

```hcl
module "googleworkspace_subdomain" {
  source = "./modules/googleworkspace"

  cloudflare_dns_zone_id = cloudflare_zone.example.id
  subdomain              = "mail"
  domain_verify_txt      = "google-site-verification=xxxxxxxxxx"
}
```

## 必須入力変数

| 変数名 | 説明 | 型 |
|--------|------|-----|
| `cloudflare_dns_zone_id` | CloudflareのZone ID | `string` |
| `domain_verify_txt` | Google Workspaceドメイン検証用のTXTレコード値 | `string` |

## オプション入力変数

| 変数名 | 説明 | 型 | デフォルト値 |
|--------|------|-----|-------------|
| `subdomain` | MXレコードを作成するサブドメイン（ルートドメインの場合は`@`） | `string` | `"@"` |
| `ttl` | DNSレコードのTTL（秒） | `number` | `3600` |
| `enable_spf` | SPFレコードを作成するか | `bool` | `true` |
| `spf_record` | SPFレコードの値 | `string` | `"v=spf1 include:_spf.google.com ~all"` |
| `dkim_records` | DKIMレコード（nameからvalueへのマップ） | `map(string)` | `{}` |
| `dmarc_record` | DMARCポリシーレコードの値 | `string` | `""` |

## 出力

| 出力名 | 説明 |
|--------|------|
| `mx_record_ids` | 作成されたMXレコードのIDリスト |
| `mx_record_hostnames` | 作成されたMXレコードのホスト名リスト |
| `spf_record_id` | SPF TXTレコードのID |
| `domain_verify_record_id` | ドメイン検証TXTレコードのID |
| `dkim_record_ids` | DKIMレコード名からIDへのマップ |
| `dmarc_record_id` | DMARC TXTレコードのID |

## Google Workspaceドメイン検証TXTレコードの取得方法

1. [Google Workspace管理コンソール](https://admin.google.com/)にログイン
2. 「アカウント」→「ドメイン」→「ドメインの管理」を選択
3. 対象ドメインの「ドメインを確認」をクリック
4. TXTレコード方式を選択し、`google-site-verification=...` の値をコピー
5. この値を `domain_verify_txt` 変数に設定

## DKIMレコードの取得方法

1. [Google Workspace管理コンソール](https://admin.google.com/)にログイン
2. 「アプリ」→「Google Workspace」→「Gmail」→「メールの認証」を選択
3. 「新しいレコードを生成」をクリック
4. 生成されたDKIM TXTレコード名と値をコピー
5. `dkim_records` 変数にマップとして設定

例：
```hcl
dkim_records = {
  "google._domainkey" = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA..."
}
```

## Google WorkspaceのMXレコード形式について

このモジュールは**レガシー形式**（5つのMXレコード）を使用しています：

- `aspmx.l.google.com` (優先度: 1)
- `alt1.aspmx.l.google.com` (優先度: 5)
- `alt2.aspmx.l.google.com` (優先度: 5)
- `alt3.aspmx.l.google.com` (優先度: 10)
- `alt4.aspmx.l.google.com` (優先度: 10)

この形式は2025年現在も引き続きサポートされています。新しいアカウントでは単一の `smtp.google.com` (優先度: 1) も利用可能ですが、既存の設定との互換性のため、レガシー形式を維持しています。

## 必要なプロバイダー

| プロバイダー | バージョン |
|-------------|-----------|
| cloudflare | 5.14.0 |

## Terraformバージョン

このモジュールはTerraform 1.14.3以上が必要です。

## ライセンス

MIT

## 参考資料

- [Google Workspace MXレコード設定](https://support.google.com/a/answer/16004259)
- [Google Workspace DNS基礎](https://support.google.com/a/answer/48090)
