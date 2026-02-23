# Naming Convention

## Harvestasya の世界観

**Harvestasya** は、テクノロジーと秩序を統括する巨大コングロマリット/SCP 財団的な組織として位置づけられる。
各サブドメインは、この組織が運用する「システム」「施設」「プロトコル」として命名される。

命名の方向性:

- 宇宙・物理学・数学の用語
- SF 的なシステム/プロトコル名
- サービスの役割・本質を反映した名前

## harvestasya.org サブドメイン命名規則

サービスの役割に合った SF/科学的な名前を付ける。

### 現在の命名マッピング

| サブドメイン | サービス | 命名由来 | 分類 |
|-------------|---------|---------|------|
| **oracle** | AdGuard Home (DNS/DoH) | Oracle = 神託/予言機関。DNS は名前解決の「全知の存在」 | 新規則 |
| **chronicle** | Immich (写真管理) | Chronicle = 年代記。写真の記録・保存 | 新規則 |
| **accounts** | Keycloak (公開) | 機能名。認証エンドポイントとして明確 | 機能名 |
| **keycloak-admin** | Keycloak (管理) | 機能名。管理コンソール | 機能名 |
| **livesync** | CouchDB/Obsidian LiveSync | 機能名。リアルタイム同期 | 機能名 |
| **grafana** | Grafana (ダッシュボード) | プロダクト名。広く認知されている | プロダクト名 |
| **prometheus** | Prometheus (メトリクス) | プロダクト名。ギリシャ神話由来で世界観に馴染む | プロダクト名 |
| **argocd** | ArgoCD (GitOps) | プロダクト名。 | プロダクト名 |
| **traefik** | Traefik (ダッシュボード) | プロダクト名。 | プロダクト名 |
| **navidrome** | Navidrome (音楽) | プロダクト名。 | プロダクト名 |
| **rss** | FreshRSS (フィード) | 機能名。 | 機能名 |
| **acme** | step-ca (証明書) | プロトコル名。ACME プロトコルそのもの | プロトコル名 |
| **vista** | Proxmox VE (Web UI) | Vista = 展望/眺望。管理画面を「見渡す」 | 新規則 |
| **tyria** | Proxmox VE (SSH) | アルトネリコ由来 (レガシー) | 旧規則 |
| **archia** | Archia SSH | アルトネリコ由来 (レガシー) | 旧規則 |
| **reyvateils** | n8n (ワークフロー) | アルトネリコ由来 (レガシー) | 旧規則 |

### 命名パターンの優先順位

1. **SF/科学名**: サービスの本質を表す概念的な名前 (oracle, chronicle, vista)
2. **機能名**: 機能が明確な場合はそのまま (accounts, livesync, rss, acme)
3. **プロダクト名**: 広く認知されたプロダクトはそのまま使用 (grafana, prometheus, argocd)

### 新規サービス追加時のガイドライン

新しいサービスを追加する際は、以下の候補パターンから選定する:

| カテゴリ | 命名候補例 | 適用例 |
|---------|-----------|--------|
| 観測・監視 | sentinel, watchtower, beacon | 監視システム |
| 記録・保存 | archive, codex, vault | ストレージ、バックアップ |
| 通信・伝達 | relay, signal, nexus | メッセージング、通知 |
| 制御・管理 | cortex, matrix, forge | オーケストレーション |
| 解析・処理 | prism, spectrum, catalyst | データ処理、変換 |
| 認証・防御 | aegis, bastion, cipher | セキュリティ |

## suzutan.jp / 内部ホスト名

suzutan.jp および LAN 内部のホスト名は、実用性を重視した機能名を使用する。

- 例: `adguard`, `pve`, `pve02`, `blog`
- 装飾的な名前は付けず、何のサービスかが即座に分かる名前にする

## 既存名の移行計画

アルトネリコ由来の名前を段階的に新規則に移行する。

### 移行候補

| 現在の名前 | サービス | 移行候補 | 優先度 | 備考 |
|-----------|---------|---------|--------|------|
| reyvateils | n8n (ワークフロー) | **automaton** | 中 | 自動化エージェント/ワークフローの意 |
| tyria | Proxmox SSH | **terminus** | 低 | ターミナルアクセスの意。vista と対になる |
| archia | Archia SSH | **gateway** | 低 | SSH ゲートウェイの意 |

### 移行方針

- DNS レコードの変更は影響範囲が大きいため、段階的に実施
- 旧名を CNAME エイリアスとして一定期間残す
- クライアント設定の更新が完了してから旧名を削除
- 移行時は PR で変更を管理し、CI で検証
