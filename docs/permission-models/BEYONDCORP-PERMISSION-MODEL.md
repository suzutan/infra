# BeyondCorp Zero Trust Permission Model

> **Status**: Active
> **Version**: 1.1.0
> **Date**: 2026-02-02

Google BeyondCorp に基づくゼロトラストアクセス制御モデル。

---

## アーキテクチャ概要

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ACCESS CONTROL ENGINE                            │
│                    (Pomerium)                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   USER              TRUST TIER           USER GROUP                 │
│   ────              ──────────           ──────────                 │
│   ・Identity        ・tier-1 (highest)   ・infra                    │
│   ・Email           ・tier-2 (high)      ・monitoring               │
│                     ・tier-3 (medium)    ・security                 │
│                     ・tier-4 (basic)     ・automation               │
│                                          ・media                    │
│                                                                     │
│                    ↓                                                │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │              ACCESS POLICY (per Resource)                    │  │
│   │                                                              │  │
│   │   Required Trust Tier: tier-2                               │  │
│   │   Required User Group: infra                                │  │
│   │                                                              │  │
│   │   User Trust Tier >= Required  AND                          │  │
│   │   User Groups contains Required                             │  │
│   │                         ↓                                    │  │
│   │                   Allow / Deny                               │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 権限構造

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   ACCESS = TRUST TIER  ×  USER GROUP                           │
│                                                                 │
│   両方の条件を満たす場合のみアクセス許可                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Trust Tier（信頼レベル）

サービスの機密度に応じたアクセスレベル。上位は下位を包含。

```
    ╭─────────────────────────────────────────────╮
    │              tier-1 (highest)               │  最高機密
    │         Core Admin Systems                  │  Keycloak, Proxmox
    ╰─────────────────────┬───────────────────────╯
                          │ ⊃
    ╭─────────────────────┴───────────────────────╮
    │              tier-2 (high)                  │  機密
    │         Infrastructure Control              │  ArgoCD, Terraform
    ╰─────────────────────┬───────────────────────╯
                          │ ⊃
    ╭─────────────────────┴───────────────────────╮
    │              tier-3 (medium)                │  内部
    │          Service Administration             │  Grafana設定, n8n編集
    ╰─────────────────────┬───────────────────────╯
                          │ ⊃
    ╭─────────────────────┴───────────────────────╮
    │              tier-4 (basic)                 │  一般
    │          Standard Access                    │  アプリ利用, 閲覧
    ╰─────────────────────────────────────────────╯
```

| Trust Tier | 説明 | 対象サービス |
|------------|------|-------------|
| **tier-1** | 最高機密。全権アクセス | Keycloak Admin, Proxmox |
| **tier-2** | インフラ制御 | ArgoCD, Terraform, 1Password |
| **tier-3** | サービス管理 | Grafana設定, n8n編集 |
| **tier-4** | 一般利用 | アプリ閲覧・利用 |

### 包含関係

```
tier-1 ⊃ tier-2 ⊃ tier-3 ⊃ tier-4

例: tier-2 のユーザーは tier-3, tier-4 が必要なサービスにもアクセス可能
```

---

## 2. User Group（ユーザーグループ）

機能領域ごとのグループ。必要なグループに所属していないとアクセス不可。

| Group | 説明 | 管轄サービス |
|-------|------|-------------|
| **infra** | インフラストラクチャ | ArgoCD, Terraform, 1Password, Traefik |
| **monitoring** | 監視・可視化 | Prometheus, Grafana, InfluxDB |
| **security** | セキュリティ・認証 | Keycloak, Pomerium |
| **automation** | 自動化 | n8n, ASF |
| **media** | メディア・保管 | Immich, Navidrome |

---

## 3. アクセス判定ロジック

リクエストごとに判定（per-request authorization）。

```
リクエスト: argocd.harvestasya.org へのアクセス

サービス要件:
  Required Trust Tier: tier-2
  Required User Group: infra

ユーザー属性 (suzutan):
  Trust Tier: tier-2
  User Groups: [infra, monitoring, automation, media]

判定:
  ✓ User Trust Tier (tier-2) >= Required (tier-2)
  ✓ User Groups contains infra

→ アクセス許可
```

```
リクエスト: qualia-admin.harvestasya.org (Keycloak Admin)

サービス要件:
  Required Trust Tier: tier-1
  Required User Group: security

ユーザー属性 (suzutan - 通常時):
  Trust Tier: tier-2
  User Groups: [infra, monitoring, automation, media]

判定:
  ✗ User Trust Tier (tier-2) < Required (tier-1)
  ✗ User Groups does not contain security

→ アクセス拒否
```

---

## 4. アクセス制御シナリオ

### シナリオ1: インフラ担当者（監視は閲覧のみ）

**要件:** ArgoCD管理者だが、Grafanaは閲覧のみ

```yaml
user: infra-admin
tier: tier-2
groups:
  - infra        # ArgoCD, Terraform アクセス可
  # monitoring なし
```

| サービス | アクセス | 理由 |
|---------|---------|------|
| ArgoCD | ✓ 可能 | tier-2 + infra |
| Grafana | ✗ 不可 | monitoring グループなし |

**Grafanaにも閲覧アクセスを許可する場合:**

```yaml
user: infra-admin
tier: tier-2
groups:
  - infra
  - monitoring   # ← 追加
```

| サービス | アクセス | アプリ内ロール |
|---------|---------|---------------|
| ArgoCD | ✓ 管理者 | - |
| Grafana | ✓ 閲覧者 | Viewer (tier-2だがmonitoring専門ではない) |

→ アプリ内ロールは `tier + group` の組み合わせで判定

---

### シナリオ2: 監視専門担当者

**要件:** Grafana管理者だが、インフラは触れない

```yaml
user: monitoring-admin
tier: tier-2           # Grafana Admin に必要
groups:
  - monitoring         # 監視系のみ
  # infra なし
```

| サービス | アクセス | アプリ内ロール |
|---------|---------|---------------|
| Grafana | ✓ 可能 | Admin (tier-2 + monitoring) |
| Prometheus | ✓ 可能 | - |
| ArgoCD | ✗ 不可 | infra グループなし |
| Terraform | ✗ 不可 | infra グループなし |

---

### シナリオ3: 開発者（本番読み取りのみ）

**要件:** n8nでワークフロー作成、Grafanaで監視確認、インフラは閲覧不可

```yaml
user: developer
tier: tier-3           # サービス管理レベル
groups:
  - automation         # n8n
  - monitoring         # Grafana 閲覧
```

| サービス | アクセス | アプリ内ロール |
|---------|---------|---------------|
| n8n | ✓ 可能 | 編集可能 (tier-3 + automation) |
| Grafana | ✓ 可能 | Editor (tier-3 + monitoring) |
| ArgoCD | ✗ 不可 | tier-2 必要 & infra なし |

---

### シナリオ4: ゲストユーザー（メディアのみ）

**要件:** 写真・音楽の閲覧のみ

```yaml
user: guest
tier: tier-4           # 一般利用
groups:
  - media              # メディアのみ
```

| サービス | アクセス |
|---------|---------|
| Immich | ✓ 可能 |
| Navidrome | ✓ 可能 |
| Grafana | ✗ 不可 |
| ArgoCD | ✗ 不可 |

---

### シナリオ5: 緊急時フルアクセス

**要件:** 障害対応で全システムにアクセス必要

```yaml
user: suzutan
tier: tier-1           # 最高権限
groups:
  - infra
  - monitoring
  - security           # ← 通常時はなし
  - automation
  - media
```

| サービス | アクセス |
|---------|---------|
| Keycloak Admin | ✓ 可能 |
| ArgoCD | ✓ 可能 |
| Grafana | ✓ Admin |
| 全サービス | ✓ 可能 |

---

### アプリ内ロールマッピングの原則

Pomeriumはアクセス可否のみ制御。アプリ内ロールは `tier × group` で判定:

```
アプリ内ロール = f(tier, group)

例: Grafana
  tier-1 or tier-2 + monitoring → Admin
  tier-3 + monitoring           → Editor
  それ以外                       → Viewer
```

**JMESPath式:**
```
role_attribute_path = (contains(groups[*], 'access.tier.tier-1') || contains(groups[*], 'access.tier.tier-2')) && contains(groups[*], 'access.group.monitoring') && 'Admin' || contains(groups[*], 'access.tier.tier-3') && contains(groups[*], 'access.group.monitoring') && 'Editor' || 'Viewer'
```

これにより「tier-2だがmonitoringグループなし」→ Viewer となる。

---

## 5. サービス別アクセス要件

| サービス | Required Tier | Required Group |
|----------|--------------|----------------|
| Keycloak Admin | tier-1 | security |
| Proxmox VE | tier-1 | (外部管理) |
| ArgoCD | tier-2 | infra |
| Terraform | tier-2 | infra |
| 1Password | tier-2 | infra |
| Traefik Dashboard | tier-2 | infra |
| Grafana | tier-4 | monitoring |
| Prometheus | tier-4 | monitoring |
| InfluxDB | tier-4 | monitoring |
| n8n | tier-3 | automation |
| ASF | tier-3 | automation |
| KubeVela | tier-2 | infra |
| Immich | tier-4 | media |
| Navidrome | tier-4 | media |

---

## 6. Keycloak グループ構造

```
/access
  /tier
    /tier-1    → access.tier.tier-1
    /tier-2    → access.tier.tier-2
    /tier-3    → access.tier.tier-3
    /tier-4    → access.tier.tier-4

  /group
    /infra       → access.group.infra
    /monitoring  → access.group.monitoring
    /security    → access.group.security
    /automation  → access.group.automation
    /media       → access.group.media
```

### グループ命名規則

```
access.tier.<tier-name>    # 信頼レベル (1つのみ割り当て)
access.group.<group-name>  # ユーザーグループ (複数可)
```

---

## 7. デフォルト権限設定

### suzutan（管理者・通常運用）

```yaml
user: suzutan
tier: tier-2              # インフラ操作可能
groups:
  - infra                 # ArgoCD, Terraform
  - monitoring            # Grafana, Prometheus
  - automation            # n8n
  - media                 # Immich, Navidrome
# security なし → Keycloak Admin アクセス不可
```

**アクセス可能:**
- ArgoCD（デプロイ・同期）
- Grafana（閲覧・設定）
- Prometheus
- n8n（編集）
- Immich, Navidrome

**アクセス不可:**
- Keycloak Admin（tier-1 + security 必要）
- Proxmox VE

### suzutan（フルアクセス時）

```yaml
user: suzutan
tier: tier-1              # 全権
groups:
  - infra
  - monitoring
  - security              # ← 追加
  - automation
  - media
```

### guest（一般利用者）

```yaml
user: guest
tier: tier-4              # 一般利用のみ
groups:
  - media                 # メディアのみ
```

**アクセス可能:**
- Immich, Navidrome

---

## 8. Pomerium Policy 設定

### 基本形式

```yaml
# Required: tier-2 + infra
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        and:
          - groups:
              has: "access.group.infra"
          - or:
              - groups:
                  has: "access.tier.tier-2"
              - groups:
                  has: "access.tier.tier-1"
```

### 各サービス設定例

```yaml
# ArgoCD: tier-2 + infra
ingress.pomerium.io/policy: |
  - allow:
      and:
        - groups:
            has: "access.group.infra"
        - or:
            - groups:
                has: "access.tier.tier-2"
            - groups:
                has: "access.tier.tier-1"
```

```yaml
# Grafana: tier-4 + monitoring
ingress.pomerium.io/policy: |
  - allow:
      and:
        - groups:
            has: "access.group.monitoring"
        - or:
            - groups:
                has: "access.tier.tier-4"
            - groups:
                has: "access.tier.tier-3"
            - groups:
                has: "access.tier.tier-2"
            - groups:
                has: "access.tier.tier-1"
```

```yaml
# n8n: tier-3 + automation
ingress.pomerium.io/policy: |
  - allow:
      and:
        - groups:
            has: "access.group.automation"
        - or:
            - groups:
                has: "access.tier.tier-3"
            - groups:
                has: "access.tier.tier-2"
            - groups:
                has: "access.tier.tier-1"
```

---

## 9. 実装ガイド

### Step 1: Keycloak グループ作成

```
Groups
└── access
    ├── tier
    │   ├── tier-1
    │   ├── tier-2
    │   ├── tier-3
    │   └── tier-4
    └── group
        ├── infra
        ├── monitoring
        ├── security
        ├── automation
        └── media
```

### Step 2: Client Scope 設定

Pomerium client に groups claim を追加:

1. Clients → `pomerium`
2. Client scopes → Add mapper
3. 設定:
   - Mapper type: `Group Membership`
   - Token Claim Name: `groups`
   - Full group path: `OFF`
   - Add to ID token: `ON`
   - Add to access token: `ON`

### Step 3: ユーザーグループ割り当て

**suzutan:**
- `/access/tier/tier-2`
- `/access/group/infra`
- `/access/group/monitoring`
- `/access/group/automation`
- `/access/group/media`

---

## 10. Google BeyondCorp との対応

| Google BeyondCorp | 本モデル | 説明 |
|-------------------|---------|------|
| Trust Tier | access.tier.* | サービス機密度に応じたレベル |
| User Groups | access.group.* | 機能領域ごとのグループ |
| Access Control Engine | Pomerium | リクエストごとの認可判定 |
| Access Policy | Ingress annotation | サービスごとの要件定義 |
| Device Inventory | (N/A) | 個人環境のため省略 |

---

## 11. 実装チェックリスト

- [ ] **Keycloak 設定**
  - [ ] `/access/tier/*` グループ作成 (4個)
  - [ ] `/access/group/*` グループ作成 (5個)
  - [ ] Client scope に groups mapper 追加
  - [ ] suzutan にグループ割り当て
- [ ] **Pomerium 設定**
  - [ ] 全 ingress-pomerium.yaml を更新
- [ ] **動作確認**
  - [ ] suzutan で ArgoCD アクセス可能
  - [ ] suzutan で Keycloak Admin アクセス不可
  - [ ] guest で Immich のみアクセス可能
