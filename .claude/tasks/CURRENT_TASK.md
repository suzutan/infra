# Task: AdGuardHome ACME自動証明書更新

**開始時刻**: 2025-12-25
**ステータス**: In Progress

## 目的

VM上のAdGuardHome（`adguard.ssa.suzutan.jp`）のTLS証明書をACMEプロトコルで自動更新できるようにする。

## 前提条件

### 既存環境
- **AdGuardHome VM**: `172.20.0.200`（Ubuntu/Debian想定）
- **step-ca**: Kubernetes上で稼働中（step-ca namespace）
- **MetalLB**: IPアドレス範囲 `172.20.0.201-172.20.0.250`
- **Cloudflare DNS**: `harvestasya.org`ゾーン管理
- **PowerDNS**: LAN内DNS（`ssa.suzutan.jp`ゾーン管理）
- **現在の証明書**: 手動設定（AdGuardHome.yamlに直接記載）

### 目標
- step-ca ACME経由で証明書を自動取得
- 証明書の自動更新（systemd timer）
- AdGuardHomeの自動再起動

## タスクフェーズ

### Phase 1: step-ca ACME provisioner設定 ⏳
- [ ] 1Password ca.jsonにACME provisioner追加
- [ ] step-certificates podを再作成して設定反映

### Phase 2: LoadBalancer Service作成 📝
- [ ] step-certificates用LoadBalancer Service作成
- [ ] MetalLBによるIP割り当て確認（172.20.0.201-250）

### Phase 3: DNS設定 📝
- [ ] Cloudflare DNSで`acme.harvestasya.org` A record追加
- [ ] DNS解決確認

### Phase 4: VM上でACMEクライアント設定 📝
- [ ] acme.shインストール
- [ ] step-ca Root CA証明書取得・信頼設定
- [ ] テスト証明書取得

### Phase 5: AdGuardHome証明書更新自動化 📝
- [ ] 証明書更新スクリプト作成
- [ ] AdGuardHome再起動スクリプト作成
- [ ] systemd timer設定
- [ ] 動作確認

## 進捗状況

### In Progress
- step-ca ACME provisioner設定

### Decisions Made

#### ACME Challenge方式
- **HTTP-01**: step-ca LoadBalancer経由でアクセス可能なため
- DNS-01は不要（PowerDNS API連携が複雑）

#### ACMEクライアント
- **acme.sh**: 軽量、systemd timer対応、hook script対応

#### ドメイン名
- **ACME CA**: `acme.harvestasya.org` → MetalLB IP（例: 172.20.0.210）
- **AdGuardHome**: `adguard.ssa.suzutan.jp` → 172.20.0.200（既存）

#### 証明書配置
- `/opt/AdGuardHome/certs/cert.pem`（証明書）
- `/opt/AdGuardHome/certs/key.pem`（秘密鍵）
- AdGuardHome.yamlは証明書ファイルパスを参照するよう変更

## 参照リソース
- [step-ca ACME](https://smallstep.com/docs/step-ca/acme-basics/)
- [acme.sh](https://github.com/acmesh-official/acme.sh)

## Modified Files
- `.claude/tasks/CURRENT_TASK.md` - タスク管理ファイル
- 1Password ca.json（UUID: 2n33wjnxjubdch4z4im4y75xb4）- ACME provisioner追加予定
- `freesia/manifests/step-ca/service-loadbalancer.yaml` - LoadBalancer Service作成予定

## Next Steps
1. ca.jsonの現在の構成確認
2. ACME provisioner設定追加
3. LoadBalancer Service作成
