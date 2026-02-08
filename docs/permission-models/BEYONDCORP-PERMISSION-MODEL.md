# BeyondCorp Zero Trust Permission Model

> **Status**: Active
> **Version**: 2.2.0
> **Date**: 2026-02-02

Google BeyondCorp に基づくゼロトラストアクセス制御モデル。
RBAC + 明示的ロールグループ方式。

---

## アーキテクチャ概要

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ACCESS CONTROL ENGINE                            │
│                    (Pomerium)                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   USER                         ROLE GROUPS                          │
│   ────                         ───────────                          │
│   ・Identity                   ・/<app>/<role>                      │
│   ・Email                                                           │
│                                例:                                  │
│                                ・/grafana/admin                     │
│                                ・/argocd/admin                      │
│                                ・/n8n/editor                        │
│                                                                     │
│                    ↓                                                │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │              ACCESS POLICY (per Resource)                    │  │
│   │                                                              │  │
│   │   Required: /grafana/admin                                   │  │
│   │            OR /grafana/editor                                │  │
│   │            OR /grafana/viewer                                │  │
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
│   ACCESS = User ∈ Required Role Group                          │
│                                                                 │
│   グループ形式: /<app>/<role>                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. ロールグループ一覧

### サービス別ロール

| サービス | Admin | Editor | Viewer |
|----------|-------|--------|--------|
| **ArgoCD** | `/argocd/admin` | - | `/argocd/viewer` |
| **Grafana** | `/grafana/admin` | `/grafana/editor` | `/grafana/viewer` |
| **Prometheus** | - | - | `/prometheus/viewer` |
| **n8n** | `/n8n/admin` | `/n8n/editor` | - |
| **Traefik** | `/traefik/admin` | - | - |
| **Immich** | `/immich/admin` | - | `/immich/viewer` |
| **Navidrome** | `/navidrome/admin` | - | `/navidrome/viewer` |
| **InfluxDB** | `/influxdb/admin` | - | `/influxdb/viewer` |
| **Keycloak** | `/keycloak/admin` | - | - |

### ロールの意味

| Role | 説明 |
|------|------|
| **admin** | 全設定変更、ユーザー管理、削除操作 |
| **editor** | コンテンツ作成・編集（設定変更は不可） |
| **viewer** | 閲覧のみ |

---

## 2. Keycloak グループ構造

```
Keycloakグループパス  →  claim/groups値 (Full group path: ON)

/argocd
  /admin     → /argocd/admin
  /viewer    → /argocd/viewer
/grafana
  /admin     → /grafana/admin
  /editor    → /grafana/editor
  /viewer    → /grafana/viewer
/prometheus
  /viewer    → /prometheus/viewer
/n8n
  /admin     → /n8n/admin
  /editor    → /n8n/editor
/traefik
  /admin     → /traefik/admin
/immich
  /admin     → /immich/admin
  /viewer    → /immich/viewer
/navidrome
  /admin     → /navidrome/admin
  /viewer    → /navidrome/viewer
/influxdb
  /admin     → /influxdb/admin
  /viewer    → /influxdb/viewer
/keycloak
  /admin     → /keycloak/admin
```

---

## 3. ユーザー権限設定

### suzutan（管理者・通常運用）

```yaml
user: suzutan
groups:
  # インフラ系 - Admin
  - /argocd/admin
  - /traefik/admin

  # 監視系 - Admin
  - /grafana/admin
  - /prometheus/viewer
  - /influxdb/admin

  # 自動化系 - Admin
  - /n8n/admin

  # メディア系 - Admin
  - /immich/admin
  - /navidrome/admin

  # セキュリティ系 - なし (通常時)
  # - /keycloak/admin  ← 必要時のみ付与
```

### suzutan（フルアクセス時）

```yaml
user: suzutan
groups:
  - /keycloak/admin   # ← 追加
  # ... 他は同じ
```

### guest（一般利用者）

```yaml
user: guest
groups:
  - /immich/viewer
  - /navidrome/viewer
```

---

## 4. Pomerium Policy 設定

### 基本形式

**重要**: Pomerium の `groups` criterion は Directory Sync（Enterprise機能）用。
OIDC claims を使用する場合は `claim/groups` を使用する。

```yaml
# 単一ロール
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        or:
          - claim/groups: /argocd/admin

# 複数ロール (いずれかで許可)
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        or:
          - claim/groups: /grafana/admin
          - claim/groups: /grafana/editor
          - claim/groups: /grafana/viewer
```

### 各サービス設定

```yaml
# ArgoCD
ingress.pomerium.io/policy: |
  - allow:
      or:
        - claim/groups: /argocd/admin
        - claim/groups: /argocd/viewer
```

```yaml
# Grafana
ingress.pomerium.io/policy: |
  - allow:
      or:
        - claim/groups: /grafana/admin
        - claim/groups: /grafana/editor
        - claim/groups: /grafana/viewer
```

```yaml
# n8n
ingress.pomerium.io/policy: |
  - allow:
      or:
        - claim/groups: /n8n/admin
        - claim/groups: /n8n/editor
```

---

## 5. アプリ内ロールマッピング

### Grafana

Pomeriumはアクセス可否のみ。Grafana内ロールはグループで判定:

```ini
# grafana.ini
role_attribute_path = contains(groups[*], '/grafana/admin') && 'Admin' || contains(groups[*], '/grafana/editor') && 'Editor' || 'Viewer'
```

| グループ | Grafana Role |
|---------|--------------|
| `/grafana/admin` | Admin |
| `/grafana/editor` | Editor |
| `/grafana/viewer` | Viewer |

---

## 6. アクセス制御シナリオ

### シナリオ1: インフラ担当者（監視は閲覧のみ）

```yaml
user: infra-admin
groups:
  - /argocd/admin
  - /traefik/admin
  - /grafana/viewer    # Editor/Admin ではない
  - /prometheus/viewer
```

| サービス | アクセス | ロール |
|---------|---------|--------|
| ArgoCD | ✓ | Admin |
| Grafana | ✓ | Viewer |

### シナリオ2: 監視専門担当者

```yaml
user: monitoring-admin
groups:
  - /grafana/admin
  - /prometheus/viewer
  - /influxdb/admin
  # argocd なし
```

| サービス | アクセス | ロール |
|---------|---------|--------|
| Grafana | ✓ | Admin |
| ArgoCD | ✗ | - |

### シナリオ3: ゲストユーザー

```yaml
user: guest
groups:
  - /immich/viewer
  - /navidrome/viewer
```

| サービス | アクセス |
|---------|---------|
| Immich | ✓ 閲覧のみ |
| Navidrome | ✓ 閲覧のみ |
| Grafana | ✗ |
| ArgoCD | ✗ |

---

## 7. 実装ガイド

### Step 1: Keycloak グループ作成

```
Groups
├── argocd
│   ├── admin
│   └── viewer
├── grafana
│   ├── admin
│   ├── editor
│   └── viewer
├── prometheus
│   └── viewer
├── n8n
│   ├── admin
│   └── editor
├── traefik
│   └── admin
├── immich
│   ├── admin
│   └── viewer
├── navidrome
│   ├── admin
│   └── viewer
├── influxdb
│   ├── admin
│   └── viewer
└── keycloak
    └── admin
```

### Step 2: Client Scope 設定

Pomerium/Grafana client に groups claim を追加:

1. Clients → `pomerium` (または `grafana`)
2. Client scopes → Add mapper
3. 設定:
   - Mapper type: `Group Membership`
   - Token Claim Name: `groups`
   - Full group path: `ON`  (重要: フルパス形式 `/app/role` を使用)
   - Add to ID token: `ON`
   - Add to access token: `ON`

### Step 3: ユーザーグループ割り当て

**suzutan:**
```
/argocd/admin
/grafana/admin
/prometheus/viewer
/n8n/admin
/traefik/admin
/immich/admin
/navidrome/admin
/influxdb/admin
```

---

## 8. 実装チェックリスト

- [x] **Keycloak 設定**
  - [x] `/<app>/<role>` グループ作成
  - [x] Client scope に groups mapper 追加 (Full group path: ON)
  - [x] suzutan にグループ割り当て
- [x] **Pomerium 設定**
  - [x] 全 ingress.yaml を `claim/groups` 形式で更新
- [x] **Grafana 設定**
  - [x] role_attribute_path を更新
- [ ] **動作確認**
  - [x] suzutan で各サービスにアクセス可能
  - [ ] suzutan で Keycloak Admin アクセス不可
  - [ ] guest で Immich/Navidrome のみ可能
