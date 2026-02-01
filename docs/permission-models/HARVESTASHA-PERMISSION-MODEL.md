# Harvestasha Tower Administration System

> **Status**: Active
> **Version**: 1.0.0
> **Date**: 2026-02-02

第三塔ハーヴェスターシャの管理システムに基づく権限モデル。

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

## 権限構造

```
┌─────────────────────────────────────────────────────────────────┐
│  TOWER LEVEL - 塔層（どこまでアクセスできるか）                  │
│  ────────────────────────────────────────────────────────────── │
│  × SERVER - 管轄領域（どの領域を担当するか）                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Tower Level（塔層）

塔の階層構造に基づいたアクセスレベル。上層ほど深い権限。

```
    ╭─────────────────────────────────────────────╮
    │           RINKERNATOR                       │  神域
    │         Tower Core Access                   │  Keycloak Admin, Proxmox
    ╰─────────────────────┬───────────────────────╯
                          │
    ╭─────────────────────┴───────────────────────╮
    │            SH_SERVER                        │  中枢
    │       Song Hymmnos Server                   │  ArgoCD, Terraform
    ╰─────────────────────┬───────────────────────╯
                          │
    ╭─────────────────────┴───────────────────────╮
    │            HYMMNOS                          │  管理層
    │         Hymmnos Layer                       │  Monitoring Admin, App Config
    ╰─────────────────────┬───────────────────────╯
                          │
    ╭─────────────────────┴───────────────────────╮
    │          BINARY_FIELD                       │  利用層
    │          バイナリ野                          │  App Usage, Dashboard View
    ╰─────────────────────┬───────────────────────╯
                          │
    ╭─────────────────────┴───────────────────────╮
    │           XP_SHELL                          │  外殻
    │          エクスペリア                        │  Auth Only
    ╰─────────────────────────────────────────────╯
```

| Level | Code | 名称 | 説明 | 対象システム |
|-------|------|------|------|-------------|
| **RINKERNATOR** | `rinkernator` | 管理者領域 | 塔の神域。全権アクセス | Keycloak Admin, Proxmox VE |
| **SH_SERVER** | `sh-server` | 詩魔法サーバー | インフラ中枢制御 | ArgoCD, Terraform, 1Password |
| **HYMMNOS** | `hymmnos` | ヒュムノス層 | 管理者向け機能 | Grafana Admin, App Settings |
| **BINARY_FIELD** | `binary-field` | バイナリ野 | 一般利用層 | App Usage, Dashboard View |
| **XP_SHELL** | `xp-shell` | エクスペリア | 認証のみ | Login Only |

### レベル包含関係

```
RINKERNATOR ⊃ SH_SERVER ⊃ HYMMNOS ⊃ BINARY_FIELD ⊃ XP_SHELL

上位レベルは下位レベルの権限を含む
```

---

## 2. Server（管轄領域）

担当する機能領域。Level と組み合わせて最終的な権限が決まる。

```
HARVESTASHA TOWER SERVERS
═══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│  SH_SERVER :: Song Hymmnos Server                          │
│  ─────────────────────────────────                         │
│  塔の中枢制御システム                                       │
│  ArgoCD, Terraform, Core Infrastructure                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  COSMOSPHERE :: コスモスフィア                              │
│  ─────────────────────────────                              │
│  監視・可視化領域                                           │
│  Prometheus, Grafana, Alerting                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  CLUSTANIA :: クラスタニア                                  │
│  ─────────────────────────────                              │
│  防衛・認証・セキュリティ領域                               │
│  Keycloak, Pomerium, Cloudflare                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  ARCHIA :: アルキア                                         │
│  ─────────────────────────                                  │
│  技術・自動化領域                                           │
│  n8n, CI/CD, Automation                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  TILIA :: ティリア                                          │
│  ─────────────────                                          │
│  メディア・保管領域                                         │
│  Immich, Navidrome, Storage                                │
└─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════
```

| Server | Code | 名称 | 管轄 |
|--------|------|------|------|
| **SH_SERVER** | `sh-server` | Song Server | ArgoCD, Terraform, 1Password |
| **COSMOSPHERE** | `cosmosphere` | コスモスフィア | Prometheus, Grafana |
| **CLUSTANIA** | `clustania` | クラスタニア | Keycloak, Pomerium |
| **ARCHIA** | `archia` | アルキア | n8n, Automation |
| **TILIA** | `tilia` | ティリア | Immich, Navidrome |

---

## 3. 現行構成とのマッピング

| 現行 | Tower Level | 説明 |
|------|-------------|------|
| Super Admin | **RINKERNATOR** | Keycloak Admin, Proxmox VE GUI |
| Infra-core / Infra-admin | **SH_SERVER** | ArgoCD, Terraform, 監視設定 |
| 一般アプリ利用 | **BINARY_FIELD** | Immich, Navidrome, Grafana閲覧 |
| 認証のみ | **XP_SHELL** | ログインはできるがアクセス先なし |

---

## 4. アクセスマトリクス

### Level × Service

| サービス | XP_SHELL | BINARY_FIELD | HYMMNOS | SH_SERVER | RINKERNATOR |
|----------|:--------:|:------------:|:-------:|:---------:|:-----------:|
| Keycloak Admin | - | - | - | - | ✓ |
| Proxmox VE | - | - | - | - | ✓ |
| ArgoCD (操作) | - | - | - | ✓ | ✓ |
| ArgoCD (閲覧) | - | - | ✓ | ✓ | ✓ |
| Terraform | - | - | - | ✓ | ✓ |
| Grafana (設定) | - | - | ✓ | ✓ | ✓ |
| Grafana (閲覧) | - | ✓ | ✓ | ✓ | ✓ |
| Prometheus | - | ✓ | ✓ | ✓ | ✓ |
| n8n (編集) | - | - | ✓ | ✓ | ✓ |
| n8n (閲覧) | - | ✓ | ✓ | ✓ | ✓ |
| Immich | - | ✓ | ✓ | ✓ | ✓ |
| Navidrome | - | ✓ | ✓ | ✓ | ✓ |

### Server × Service

| サービス | 必要な Server |
|----------|---------------|
| ArgoCD | SH_SERVER |
| Terraform | SH_SERVER |
| 1Password | SH_SERVER |
| Grafana | COSMOSPHERE |
| Prometheus | COSMOSPHERE |
| Keycloak | CLUSTANIA |
| Pomerium | CLUSTANIA |
| n8n | ARCHIA |
| Immich | TILIA |
| Navidrome | TILIA |

---

## 5. Keycloak グループ構造

```
/tower
  /level
    /rinkernator    → tower.level.rinkernator
    /sh-server      → tower.level.sh-server
    /hymmnos        → tower.level.hymmnos
    /binary-field   → tower.level.binary-field
    /xp-shell       → tower.level.xp-shell

  /server
    /sh-server      → tower.server.sh-server
    /cosmosphere    → tower.server.cosmosphere
    /clustania      → tower.server.clustania
    /archia         → tower.server.archia
    /tilia          → tower.server.tilia
```

### グループ命名規則

```
tower.level.<level-name>
tower.server.<server-name>
```

---

## 6. ロールプロファイル例

### Tower Administrator（あなた・通常時）

```yaml
user: suzutan
level: sh-server
servers:
  - sh-server
  - cosmosphere
  - archia
  - tilia
```

**アクセス可能:**
- ArgoCD（閲覧・操作）
- Grafana（閲覧・設定）
- Prometheus
- n8n（閲覧・編集）
- Immich, Navidrome

**アクセス不可:**
- Keycloak Admin
- Proxmox VE GUI

### Tower Administrator（あなた・フル権限時）

```yaml
user: suzutan
level: rinkernator
servers:
  - sh-server
  - cosmosphere
  - clustania
  - archia
  - tilia
```

**アクセス可能:**
- 全システム

### 一般利用者（家族・友人）

```yaml
user: guest
level: binary-field
servers:
  - tilia
```

**アクセス可能:**
- Immich（写真閲覧）
- Navidrome（音楽再生）

**アクセス不可:**
- 管理系全般
- 監視系

### 監視専用（外部モニタリング）

```yaml
user: monitoring-bot
level: binary-field
servers:
  - cosmosphere
```

**アクセス可能:**
- Grafana（閲覧のみ）
- Prometheus（クエリのみ）

---

## 7. Pomerium Policy

```yaml
routes:
  # ============================================================
  # RINKERNATOR Level - 神域
  # ============================================================

  # Keycloak Admin
  - from: https://qualia-admin.harvestasya.org
    to: http://keycloak.keycloak.svc.cluster.local:8080
    policy:
      - allow:
          groups:
            has: "tower.level.rinkernator"

  # ============================================================
  # SH_SERVER Level - 中枢
  # ============================================================

  # ArgoCD
  - from: https://argocd.harvestasya.org
    to: http://argocd-server.argocd.svc.cluster.local
    policy:
      - allow:
          and:
            - groups:
                has: "tower.server.sh-server"
            - or:
                - groups:
                    has: "tower.level.sh-server"
                - groups:
                    has: "tower.level.rinkernator"

  # ============================================================
  # HYMMNOS Level - 管理層
  # ============================================================

  # Grafana (設定含む)
  - from: https://grafana.harvestasya.org
    to: http://grafana.temporis.svc.cluster.local:3000
    policy:
      - allow:
          and:
            - groups:
                has: "tower.server.cosmosphere"
            - or:
                - groups:
                    has: "tower.level.hymmnos"
                - groups:
                    has: "tower.level.sh-server"
                - groups:
                    has: "tower.level.rinkernator"

  # n8n
  - from: https://n8n.harvestasya.org
    to: http://n8n.n8n.svc.cluster.local:5678
    policy:
      - allow:
          and:
            - groups:
                has: "tower.server.archia"
            - or:
                - groups:
                    has: "tower.level.hymmnos"
                - groups:
                    has: "tower.level.sh-server"
                - groups:
                    has: "tower.level.rinkernator"

  # ============================================================
  # BINARY_FIELD Level - 利用層
  # ============================================================

  # Immich
  - from: https://chronicle.harvestasya.org
    to: http://immich-server.immich.svc.cluster.local:2283
    policy:
      - allow:
          and:
            - groups:
                has: "tower.server.tilia"
            - or:
                - groups:
                    has: "tower.level.binary-field"
                - groups:
                    has: "tower.level.hymmnos"
                - groups:
                    has: "tower.level.sh-server"
                - groups:
                    has: "tower.level.rinkernator"

  # Navidrome
  - from: https://navidrome.harvestasya.org
    to: http://navidrome.navidrome.svc.cluster.local:4533
    policy:
      - allow:
          and:
            - groups:
                has: "tower.server.tilia"
            - or:
                - groups:
                    has: "tower.level.binary-field"
                - groups:
                    has: "tower.level.hymmnos"
                - groups:
                    has: "tower.level.sh-server"
                - groups:
                    has: "tower.level.rinkernator"
```

---

## 8. 視覚的サマリー

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HARVESTASHA ACCESS MODEL                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  LEVEL              SERVERS              SERVICES                   │
│  ─────              ───────              ────────                   │
│                                                                     │
│  RINKERNATOR ─────► CLUSTANIA ─────────► Keycloak Admin            │
│      │                                   Proxmox VE                 │
│      │                                                              │
│      ▼                                                              │
│  SH_SERVER ───────► SH_SERVER ─────────► ArgoCD                    │
│      │                                   Terraform                  │
│      │                                   1Password                  │
│      │                                                              │
│      ▼                                                              │
│  HYMMNOS ─────────► COSMOSPHERE ───────► Grafana (Admin)           │
│      │              ARCHIA ────────────► n8n (Edit)                │
│      │                                                              │
│      ▼                                                              │
│  BINARY_FIELD ────► COSMOSPHERE ───────► Grafana (View)            │
│      │              ARCHIA ────────────► n8n (View)                │
│      │              TILIA ─────────────► Immich                    │
│      │                                   Navidrome                  │
│      │                                                              │
│      ▼                                                              │
│  XP_SHELL ────────► (none) ────────────► Login Only                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 9. 用語集

| 用語 | 意味 | 元ネタ |
|------|------|--------|
| **Harvestasha** | 塔の名前、このシステム全体 | 第三塔ハーヴェスターシャ |
| **Rinkernator** | 塔の最深部、神域 | リンカーネイター（塔の核） |
| **SH Server** | 詩魔法を処理する中枢 | Song Hymmnos Server |
| **Hymmnos** | 詩魔法言語、管理者層 | ヒュムノス語 |
| **Binary Field** | データが実行される場所 | バイナリ野 |
| **XP Shell** | 塔の外殻 | エクスペリア |
| **Cosmosphere** | 精神世界、可視化 | コスモスフィア |
| **Clustania** | 軍事国家、防衛 | クラスタニア |
| **Archia** | 学術都市、技術 | アルキア |
| **Tilia** | 塔の人格の一つ | ティリア |

---

## 10. デフォルト権限設定

### suzutan（管理者・通常運用）

```yaml
user: suzutan
level: sh-server      # インフラ操作可能、ただし Keycloak/Proxmox は除外
servers:
  - sh-server         # ArgoCD, Terraform
  - cosmosphere       # Grafana, Prometheus
  - archia            # n8n
  - tilia             # Immich, Navidrome
# clustania は含めない → Keycloak Admin へのアクセス不可
```

**できること:**
- ArgoCD でデプロイ・同期
- Grafana でダッシュボード閲覧・設定
- n8n でワークフロー編集
- Immich, Navidrome 利用

**できないこと:**
- Keycloak Admin Console
- Proxmox VE GUI
- Pomerium 設定変更

### suzutan（フルアクセスが必要な時）

```yaml
user: suzutan
level: rinkernator    # 全権
servers:
  - sh-server
  - cosmosphere
  - clustania         # ← 追加
  - archia
  - tilia
```

---

## 11. 実装ガイド

### Step 1: Keycloak グループ作成

Keycloak Admin Console (`qualia-admin.harvestasya.org`) で以下のグループを作成:

```
Groups
└── tower
    ├── level
    │   ├── rinkernator
    │   ├── sh-server
    │   ├── hymmnos
    │   ├── binary-field
    │   └── xp-shell
    └── server
        ├── sh-server
        ├── cosmosphere
        ├── clustania
        ├── archia
        └── tilia
```

**作成手順:**
1. Keycloak Admin → Realm 選択 → Groups
2. "Create group" で `tower` 作成
3. `tower` を選択 → "Create subgroup" で `level`, `server` 作成
4. 各サブグループ配下に上記グループを作成

### Step 2: グループ属性設定（Mapper用）

各グループにグループ名を設定（Pomerium で使用）:

| グループパス | 設定する属性名 |
|-------------|---------------|
| `/tower/level/rinkernator` | `tower.level.rinkernator` |
| `/tower/level/sh-server` | `tower.level.sh-server` |
| `/tower/level/hymmnos` | `tower.level.hymmnos` |
| `/tower/level/binary-field` | `tower.level.binary-field` |
| `/tower/level/xp-shell` | `tower.level.xp-shell` |
| `/tower/server/sh-server` | `tower.server.sh-server` |
| `/tower/server/cosmosphere` | `tower.server.cosmosphere` |
| `/tower/server/clustania` | `tower.server.clustania` |
| `/tower/server/archia` | `tower.server.archia` |
| `/tower/server/tilia` | `tower.server.tilia` |

### Step 3: Client Scope 設定（Pomerium 用）

Keycloak で Pomerium client に groups claim を追加:

1. Clients → `pomerium` (または該当クライアント)
2. Client scopes → `pomerium-dedicated` → Add mapper
3. Mapper 設定:
   - Mapper type: `Group Membership`
   - Name: `groups`
   - Token Claim Name: `groups`
   - Full group path: `OFF`
   - Add to ID token: `ON`
   - Add to access token: `ON`
   - Add to userinfo: `ON`

### Step 4: ユーザーへのグループ割り当て

**suzutan（通常運用）:**
1. Users → suzutan → Groups
2. Join groups:
   - `/tower/level/sh-server`
   - `/tower/server/sh-server`
   - `/tower/server/cosmosphere`
   - `/tower/server/archia`
   - `/tower/server/tilia`

### Step 5: Pomerium Policy 設定

各アプリの Ingress に policy を追加。例:

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
                has: "tower.server.sh-server"
            - or:
                - groups:
                    has: "tower.level.sh-server"
                - groups:
                    has: "tower.level.rinkernator"
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

---

## 12. 各サービス設定一覧

### ArgoCD

| 項目 | 設定値 |
|------|--------|
| Level 要件 | `sh-server` 以上 |
| Server 要件 | `sh-server` |
| Ingress | `ingress-pomerium.yaml` |

```yaml
# Policy
- allow:
    and:
      - groups:
          has: "tower.server.sh-server"
      - or:
          - groups:
              has: "tower.level.sh-server"
          - groups:
              has: "tower.level.rinkernator"
```

### Grafana

| 項目 | 設定値 |
|------|--------|
| Level 要件 | `binary-field` 以上（閲覧） / `hymmnos` 以上（設定） |
| Server 要件 | `cosmosphere` |
| Ingress | `ingress-pomerium.yaml` |

```yaml
# Policy (閲覧)
- allow:
    and:
      - groups:
          has: "tower.server.cosmosphere"
      - or:
          - groups:
              has: "tower.level.binary-field"
          - groups:
              has: "tower.level.hymmnos"
          - groups:
              has: "tower.level.sh-server"
          - groups:
              has: "tower.level.rinkernator"
```

### n8n

| 項目 | 設定値 |
|------|--------|
| Level 要件 | `hymmnos` 以上 |
| Server 要件 | `archia` |
| Ingress | `ingress-pomerium.yaml` |

```yaml
# Policy
- allow:
    and:
      - groups:
          has: "tower.server.archia"
      - or:
          - groups:
              has: "tower.level.hymmnos"
          - groups:
              has: "tower.level.sh-server"
          - groups:
              has: "tower.level.rinkernator"
```

### Immich (chronicle)

| 項目 | 設定値 |
|------|--------|
| Level 要件 | `binary-field` 以上 |
| Server 要件 | `tilia` |
| Ingress | Traefik 経由（policy なし） |

**注**: Immich は Pomerium を経由せず Traefik 直通のため、Keycloak での認証のみ。

### Navidrome

| 項目 | 設定値 |
|------|--------|
| Level 要件 | `binary-field` 以上 |
| Server 要件 | `tilia` |
| Ingress | `ingress-pomerium.yaml` |

```yaml
# Policy
- allow:
    and:
      - groups:
          has: "tower.server.tilia"
      - or:
          - groups:
              has: "tower.level.binary-field"
          - groups:
              has: "tower.level.hymmnos"
          - groups:
              has: "tower.level.sh-server"
          - groups:
              has: "tower.level.rinkernator"
```

### Keycloak Admin

| 項目 | 設定値 |
|------|--------|
| Level 要件 | `rinkernator` のみ |
| Server 要件 | `clustania` |
| Ingress | Traefik 経由 + Cloudflare Access |

```yaml
# Policy (Pomerium使用時)
- allow:
    and:
      - groups:
          has: "tower.server.clustania"
      - groups:
          has: "tower.level.rinkernator"
```

---

## 13. 実装チェックリスト

- [ ] **Keycloak 設定**
  - [ ] `/tower/level/*` グループ作成 (5個)
  - [ ] `/tower/server/*` グループ作成 (5個)
  - [ ] Client scope に groups mapper 追加
  - [ ] suzutan にグループ割り当て
- [ ] **Pomerium 設定**
  - [ ] ArgoCD ingress-pomerium.yaml 更新
  - [ ] Grafana ingress-pomerium.yaml 更新
  - [ ] n8n ingress-pomerium.yaml 更新
  - [ ] Navidrome ingress-pomerium.yaml 更新
- [ ] **動作確認**
  - [ ] suzutan で ArgoCD アクセス可能
  - [ ] suzutan で Keycloak Admin アクセス不可
  - [ ] guest ユーザーで Immich のみアクセス可能
