# Harvestasha Tower Administration System

> **Status**: Active
> **Version**: 2.0.0
> **Date**: 2026-02-02

第三塔ハーヴェスターシャの管理システムに基づく権限モデル。
Google BeyondCorp のゼロトラストアーキテクチャを参考に設計。

---

## The Tower

```
╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║    ██╗  ██╗ █████╗ ██████╗ ██╗   ██╗███████╗███████╗████████╗     ║
║    ██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝     ║
║    ███████║███████║██████╔╝██║   ██║█████╗  ███████╗   ██║        ║
║    ██╔══██║██╔══██║██╔══██╗╚██╗ ██╔╝██╔══╝  ╚════██║   ██║        ║
║    ██║  ██║██║  ██║██║  ██║ ╚████╔╝ ███████╗███████║   ██║        ║
║    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚══════╝   ╚═╝        ║
║                                                                    ║
║     █████╗ ███████╗██╗  ██╗ █████╗                                ║
║    ██╔══██╗██╔════╝██║  ██║██╔══██╗                               ║
║    ███████║███████╗███████║███████║                               ║
║    ██╔══██║╚════██║██╔══██║██╔══██║                               ║
║    ██║  ██║███████║██║  ██║██║  ██║                               ║
║    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝                               ║
║                                                                    ║
║    TOWER ADMINISTRATION SYSTEM                                     ║
║    "Ar Ciel shall be reborn through The Tower's will."            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## アーキテクチャ概要

Google BeyondCorp に基づくゼロトラスト設計。

```
┌─────────────────────────────────────────────────────────────────────┐
│                 TOWER ACCESS CONTROL ENGINE                         │
│                 (Pomerium)                                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   OPERATIVE         TRUST TIER           DIVISION                   │
│   (User)            (信頼レベル)          (所属グループ)             │
│   ─────────         ──────────           ──────────                 │
│   ・Identity        ・RINKERNATOR        ・SH_SERVER                │
│   ・Email           ・SH_SERVER          ・COSMOSPHERE              │
│                     ・HYMMNOS            ・CLUSTANIA                │
│                     ・BINARY_FIELD       ・ARCHIA                   │
│                                          ・TILIA                    │
│                                                                     │
│                    ↓                                                │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │              ACCESS POLICY (per Resource)                    │  │
│   │                                                              │  │
│   │   Required Trust Tier: SH_SERVER                            │  │
│   │   Required Division:   SH_SERVER                            │  │
│   │                                                              │  │
│   │   User Trust Tier >= Required  AND                          │  │
│   │   User Division contains Required                           │  │
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
│   ACCESS = TRUST TIER  ×  DIVISION                             │
│            (信頼レベル)    (所属グループ)                        │
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
    │         RINKERNATOR (神域)                  │  最高機密
    │         Tower Core / Admin Systems          │  Keycloak, Proxmox
    ╰─────────────────────┬───────────────────────╯
                          │ ⊃
    ╭─────────────────────┴───────────────────────╮
    │          SH_SERVER (中枢)                   │  機密
    │         Infrastructure Control              │  ArgoCD, Terraform
    ╰─────────────────────┬───────────────────────╯
                          │ ⊃
    ╭─────────────────────┴───────────────────────╮
    │           HYMMNOS (管理)                    │  内部
    │          Service Administration             │  Grafana設定, n8n編集
    ╰─────────────────────┬───────────────────────╯
                          │ ⊃
    ╭─────────────────────┴───────────────────────╮
    │         BINARY_FIELD (利用)                 │  一般
    │          Standard Access                    │  アプリ利用, 閲覧
    ╰─────────────────────────────────────────────╯
```

| Trust Tier | Code | Google対応 | 説明 |
|------------|------|-----------|------|
| **RINKERNATOR** | `rinkernator` | Highest Trust | 塔の神域。全権アクセス |
| **SH_SERVER** | `sh-server` | High Trust | インフラ中枢制御 |
| **HYMMNOS** | `hymmnos` | Medium Trust | 管理者向け機能 |
| **BINARY_FIELD** | `binary-field` | Basic Trust | 一般利用 |

### 包含関係

```
RINKERNATOR ⊃ SH_SERVER ⊃ HYMMNOS ⊃ BINARY_FIELD

例: Trust Tier = SH_SERVER のユーザーは
    HYMMNOS, BINARY_FIELD が必要なサービスにもアクセス可能
```

---

## 2. Division（所属グループ）

機能領域ごとのグループ。**必要な Division に所属していないとアクセス不可**。

```
HARVESTASHA DIVISIONS
═══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│  SH_SERVER :: Song Hymmnos Server                          │
│  塔の中枢制御システム                                       │
│  ArgoCD, Terraform, 1Password                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  COSMOSPHERE :: コスモスフィア                              │
│  監視・可視化領域                                           │
│  Prometheus, Grafana                                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  CLUSTANIA :: クラスタニア                                  │
│  防衛・認証領域                                             │
│  Keycloak, Pomerium                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  ARCHIA :: アルキア                                         │
│  技術・自動化領域                                           │
│  n8n, Automation                                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  TILIA :: ティリア                                          │
│  メディア・保管領域                                         │
│  Immich, Navidrome                                         │
└─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════
```

| Division | Code | 管轄サービス |
|----------|------|-------------|
| **SH_SERVER** | `sh-server` | ArgoCD, Terraform, 1Password |
| **COSMOSPHERE** | `cosmosphere` | Prometheus, Grafana |
| **CLUSTANIA** | `clustania` | Keycloak, Pomerium |
| **ARCHIA** | `archia` | n8n, Automation |
| **TILIA** | `tilia` | Immich, Navidrome |

---

## 3. アクセス判定ロジック

Google BeyondCorp と同様、**リクエストごとに判定**。

```
リクエスト: argocd.harvestasya.org へのアクセス

サービス要件:
  Required Trust Tier: SH_SERVER
  Required Division:   SH_SERVER

ユーザー属性 (suzutan):
  Trust Tier: SH_SERVER
  Divisions:  [SH_SERVER, COSMOSPHERE, ARCHIA, TILIA]

判定:
  ✓ User Trust Tier (SH_SERVER) >= Required (SH_SERVER)
  ✓ User Divisions contains SH_SERVER

→ アクセス許可
```

```
リクエスト: qualia-admin.harvestasya.org (Keycloak Admin)

サービス要件:
  Required Trust Tier: RINKERNATOR
  Required Division:   CLUSTANIA

ユーザー属性 (suzutan - 通常時):
  Trust Tier: SH_SERVER
  Divisions:  [SH_SERVER, COSMOSPHERE, ARCHIA, TILIA]

判定:
  ✗ User Trust Tier (SH_SERVER) < Required (RINKERNATOR)
  ✗ User Divisions does not contain CLUSTANIA

→ アクセス拒否
```

---

## 4. サービス別アクセス要件

| サービス | Required Trust Tier | Required Division |
|----------|--------------------|--------------------|
| Keycloak Admin | RINKERNATOR | CLUSTANIA |
| Proxmox VE | RINKERNATOR | (外部管理) |
| ArgoCD | SH_SERVER | SH_SERVER |
| Terraform | SH_SERVER | SH_SERVER |
| 1Password | SH_SERVER | SH_SERVER |
| Grafana (設定) | HYMMNOS | COSMOSPHERE |
| Grafana (閲覧) | BINARY_FIELD | COSMOSPHERE |
| Prometheus | BINARY_FIELD | COSMOSPHERE |
| n8n | HYMMNOS | ARCHIA |
| Immich | BINARY_FIELD | TILIA |
| Navidrome | BINARY_FIELD | TILIA |

---

## 5. Keycloak グループ構造

```
/tower
  /tier                           # Trust Tier (信頼レベル)
    /rinkernator    → tower.tier.rinkernator
    /sh-server      → tower.tier.sh-server
    /hymmnos        → tower.tier.hymmnos
    /binary-field   → tower.tier.binary-field

  /division                       # Division (所属グループ)
    /sh-server      → tower.division.sh-server
    /cosmosphere    → tower.division.cosmosphere
    /clustania      → tower.division.clustania
    /archia         → tower.division.archia
    /tilia          → tower.division.tilia
```

### グループ命名規則

```
tower.tier.<tier-name>         # 信頼レベル (1つのみ割り当て)
tower.division.<division-name>  # 所属グループ (複数可)
```

---

## 6. デフォルト権限設定

### suzutan（管理者・通常運用）

```yaml
user: suzutan
tier: sh-server           # インフラ操作可能
divisions:
  - sh-server             # ArgoCD, Terraform
  - cosmosphere           # Grafana, Prometheus
  - archia                # n8n
  - tilia                 # Immich, Navidrome
# clustania なし → Keycloak Admin アクセス不可
```

**アクセス可能:**
- ArgoCD（デプロイ・同期）
- Grafana（閲覧・設定）
- Prometheus
- n8n（編集）
- Immich, Navidrome

**アクセス不可:**
- Keycloak Admin（RINKERNATOR + CLUSTANIA 必要）
- Proxmox VE

### suzutan（フルアクセス時）

```yaml
user: suzutan
tier: rinkernator         # 全権
divisions:
  - sh-server
  - cosmosphere
  - clustania             # ← 追加
  - archia
  - tilia
```

### guest（一般利用者）

```yaml
user: guest
tier: binary-field        # 一般利用のみ
divisions:
  - tilia                 # メディアのみ
```

**アクセス可能:**
- Immich, Navidrome

---

## 7. Pomerium Policy 設定

### 基本形式

```yaml
# Required Trust Tier: SH_SERVER
# Required Division: SH_SERVER
policy:
  - allow:
      and:
        - groups:
            has: "tower.division.sh-server"    # Division チェック
        - or:                                   # Trust Tier チェック (上位も許可)
            - groups:
                has: "tower.tier.sh-server"
            - groups:
                has: "tower.tier.rinkernator"
```

### 各サービス設定

```yaml
# k8s/manifests/argocd/ingress-pomerium.yaml
apiVersion: ingress.pomerium.io/v1
kind: Ingress
metadata:
  name: argocd
  namespace: argocd
  annotations:
    ingress.pomerium.io/policy: |
      - allow:
          and:
            - groups:
                has: "tower.division.sh-server"
            - or:
                - groups:
                    has: "tower.tier.sh-server"
                - groups:
                    has: "tower.tier.rinkernator"
spec:
  ingressClassName: pomerium
  rules:
    - host: argocd.harvestasya.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
```

```yaml
# k8s/manifests/temporis/grafana/ingress-pomerium.yaml
# Required: BINARY_FIELD + COSMOSPHERE
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        and:
          - groups:
              has: "tower.division.cosmosphere"
          - or:
              - groups:
                  has: "tower.tier.binary-field"
              - groups:
                  has: "tower.tier.hymmnos"
              - groups:
                  has: "tower.tier.sh-server"
              - groups:
                  has: "tower.tier.rinkernator"
```

```yaml
# k8s/manifests/n8n/ingress-pomerium.yaml
# Required: HYMMNOS + ARCHIA
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        and:
          - groups:
              has: "tower.division.archia"
          - or:
              - groups:
                  has: "tower.tier.hymmnos"
              - groups:
                  has: "tower.tier.sh-server"
              - groups:
                  has: "tower.tier.rinkernator"
```

```yaml
# k8s/manifests/navidrome/ingress-pomerium.yaml
# Required: BINARY_FIELD + TILIA
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        and:
          - groups:
              has: "tower.division.tilia"
          - or:
              - groups:
                  has: "tower.tier.binary-field"
              - groups:
                  has: "tower.tier.hymmnos"
              - groups:
                  has: "tower.tier.sh-server"
              - groups:
                  has: "tower.tier.rinkernator"
```

---

## 8. 実装ガイド

### Step 1: Keycloak グループ作成

```
Groups
└── tower
    ├── tier
    │   ├── rinkernator
    │   ├── sh-server
    │   ├── hymmnos
    │   └── binary-field
    └── division
        ├── sh-server
        ├── cosmosphere
        ├── clustania
        ├── archia
        └── tilia
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
- `/tower/tier/sh-server`
- `/tower/division/sh-server`
- `/tower/division/cosmosphere`
- `/tower/division/archia`
- `/tower/division/tilia`

### Step 4: Pomerium Ingress 更新

各サービスの `ingress-pomerium.yaml` に policy annotation を追加。

---

## 9. Google BeyondCorp との対応表

| Google BeyondCorp | Harvestasha | 説明 |
|-------------------|-------------|------|
| Trust Tier | tower.tier.* | サービス機密度に応じたレベル |
| User Groups | tower.division.* | 機能領域ごとのグループ |
| Access Control Engine | Pomerium | リクエストごとの認可判定 |
| Access Policy | Ingress annotation | サービスごとの要件定義 |
| Device Inventory | (N/A) | 個人環境のため省略 |

---

## 10. 用語集

| 用語 | 意味 | 元ネタ |
|------|------|--------|
| **Harvestasha** | このシステム全体 | 第三塔ハーヴェスターシャ |
| **Rinkernator** | 最高信頼レベル | リンカーネイター（塔の核） |
| **SH Server** | 高信頼レベル | Song Hymmnos Server |
| **Hymmnos** | 中信頼レベル | ヒュムノス語 |
| **Binary Field** | 基本信頼レベル | バイナリ野 |
| **Cosmosphere** | 監視グループ | コスモスフィア |
| **Clustania** | セキュリティグループ | クラスタニア |
| **Archia** | 自動化グループ | アルキア |
| **Tilia** | メディアグループ | ティリア |

---

## 11. 実装チェックリスト

- [ ] **Keycloak 設定**
  - [ ] `/tower/tier/*` グループ作成 (4個)
  - [ ] `/tower/division/*` グループ作成 (5個)
  - [ ] Client scope に groups mapper 追加
  - [ ] suzutan にグループ割り当て
- [ ] **Pomerium 設定**
  - [ ] ArgoCD ingress-pomerium.yaml
  - [ ] Grafana ingress-pomerium.yaml
  - [ ] n8n ingress-pomerium.yaml
  - [ ] Navidrome ingress-pomerium.yaml
- [ ] **動作確認**
  - [ ] suzutan で ArgoCD アクセス可能
  - [ ] suzutan で Keycloak Admin アクセス不可
  - [ ] guest で Immich のみアクセス可能
