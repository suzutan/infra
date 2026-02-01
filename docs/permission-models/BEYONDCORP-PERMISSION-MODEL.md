# BeyondCorp Zero Trust Permission Model

> **Status**: Active
> **Version**: 2.0.0
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
│   ・Identity                   ・access.group.<app>.<role>          │
│   ・Email                                                           │
│                                例:                                  │
│                                ・access.group.grafana.admin         │
│                                ・access.group.argocd.admin          │
│                                ・access.group.n8n.editor            │
│                                                                     │
│                    ↓                                                │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │              ACCESS POLICY (per Resource)                    │  │
│   │                                                              │  │
│   │   Required: access.group.grafana.admin                      │  │
│   │            OR access.group.grafana.editor                   │  │
│   │            OR access.group.grafana.viewer                   │  │
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
│   グループ形式: access.group.<app>.<role>                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. ロールグループ一覧

### サービス別ロール

| サービス | Admin | Editor | Viewer |
|----------|-------|--------|--------|
| **ArgoCD** | `access.group.argocd.admin` | - | `access.group.argocd.viewer` |
| **Grafana** | `access.group.grafana.admin` | `access.group.grafana.editor` | `access.group.grafana.viewer` |
| **Prometheus** | - | - | `access.group.prometheus.viewer` |
| **n8n** | `access.group.n8n.admin` | `access.group.n8n.editor` | - |
| **Traefik** | `access.group.traefik.admin` | - | - |
| **Immich** | `access.group.immich.admin` | - | `access.group.immich.viewer` |
| **Navidrome** | `access.group.navidrome.admin` | - | `access.group.navidrome.viewer` |
| **ASF** | `access.group.asf.admin` | - | - |
| **KubeVela** | `access.group.kubevela.admin` | - | - |
| **InfluxDB** | `access.group.influxdb.admin` | - | `access.group.influxdb.viewer` |
| **Keycloak** | `access.group.keycloak.admin` | - | - |

### ロールの意味

| Role | 説明 |
|------|------|
| **admin** | 全設定変更、ユーザー管理、削除操作 |
| **editor** | コンテンツ作成・編集（設定変更は不可） |
| **viewer** | 閲覧のみ |

---

## 2. Keycloak グループ構造

```
/access
  /group
    /argocd
      /admin     → access.group.argocd.admin
      /viewer    → access.group.argocd.viewer
    /grafana
      /admin     → access.group.grafana.admin
      /editor    → access.group.grafana.editor
      /viewer    → access.group.grafana.viewer
    /prometheus
      /viewer    → access.group.prometheus.viewer
    /n8n
      /admin     → access.group.n8n.admin
      /editor    → access.group.n8n.editor
    /traefik
      /admin     → access.group.traefik.admin
    /immich
      /admin     → access.group.immich.admin
      /viewer    → access.group.immich.viewer
    /navidrome
      /admin     → access.group.navidrome.admin
      /viewer    → access.group.navidrome.viewer
    /asf
      /admin     → access.group.asf.admin
    /kubevela
      /admin     → access.group.kubevela.admin
    /influxdb
      /admin     → access.group.influxdb.admin
      /viewer    → access.group.influxdb.viewer
    /keycloak
      /admin     → access.group.keycloak.admin
```

---

## 3. ユーザー権限設定

### suzutan（管理者・通常運用）

```yaml
user: suzutan
groups:
  # インフラ系 - Admin
  - access.group.argocd.admin
  - access.group.traefik.admin
  - access.group.kubevela.admin

  # 監視系 - Admin
  - access.group.grafana.admin
  - access.group.prometheus.viewer
  - access.group.influxdb.admin

  # 自動化系 - Admin
  - access.group.n8n.admin
  - access.group.asf.admin

  # メディア系 - Admin
  - access.group.immich.admin
  - access.group.navidrome.admin

  # セキュリティ系 - なし (通常時)
  # - access.group.keycloak.admin  ← 必要時のみ付与
```

### suzutan（フルアクセス時）

```yaml
user: suzutan
groups:
  - access.group.keycloak.admin   # ← 追加
  # ... 他は同じ
```

### guest（一般利用者）

```yaml
user: guest
groups:
  - access.group.immich.viewer
  - access.group.navidrome.viewer
```

---

## 4. Pomerium Policy 設定

### 基本形式

```yaml
# 単一ロール
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        or:
          - groups:
              has: "access.group.argocd.admin"

# 複数ロール (いずれかで許可)
annotations:
  ingress.pomerium.io/policy: |
    - allow:
        or:
          - groups:
              has: "access.group.grafana.admin"
          - groups:
              has: "access.group.grafana.editor"
          - groups:
              has: "access.group.grafana.viewer"
```

### 各サービス設定

```yaml
# ArgoCD
ingress.pomerium.io/policy: |
  - allow:
      or:
        - groups:
            has: "access.group.argocd.admin"
        - groups:
            has: "access.group.argocd.viewer"
```

```yaml
# Grafana
ingress.pomerium.io/policy: |
  - allow:
      or:
        - groups:
            has: "access.group.grafana.admin"
        - groups:
            has: "access.group.grafana.editor"
        - groups:
            has: "access.group.grafana.viewer"
```

```yaml
# n8n
ingress.pomerium.io/policy: |
  - allow:
      or:
        - groups:
            has: "access.group.n8n.admin"
        - groups:
            has: "access.group.n8n.editor"
```

---

## 5. アプリ内ロールマッピング

### Grafana

Pomeriumはアクセス可否のみ。Grafana内ロールはグループで判定:

```ini
# grafana.ini
role_attribute_path = contains(groups[*], 'access.group.grafana.admin') && 'Admin' || contains(groups[*], 'access.group.grafana.editor') && 'Editor' || 'Viewer'
```

| グループ | Grafana Role |
|---------|--------------|
| `access.group.grafana.admin` | Admin |
| `access.group.grafana.editor` | Editor |
| `access.group.grafana.viewer` | Viewer |

---

## 6. アクセス制御シナリオ

### シナリオ1: インフラ担当者（監視は閲覧のみ）

```yaml
user: infra-admin
groups:
  - access.group.argocd.admin
  - access.group.traefik.admin
  - access.group.grafana.viewer    # Editor/Admin ではない
  - access.group.prometheus.viewer
```

| サービス | アクセス | ロール |
|---------|---------|--------|
| ArgoCD | ✓ | Admin |
| Grafana | ✓ | Viewer |

### シナリオ2: 監視専門担当者

```yaml
user: monitoring-admin
groups:
  - access.group.grafana.admin
  - access.group.prometheus.viewer
  - access.group.influxdb.admin
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
  - access.group.immich.viewer
  - access.group.navidrome.viewer
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
└── access
    └── group
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
        ├── asf
        │   └── admin
        ├── kubevela
        │   └── admin
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
   - Full group path: `OFF`
   - Add to ID token: `ON`
   - Add to access token: `ON`

### Step 3: ユーザーグループ割り当て

**suzutan:**
```
/access/group/argocd/admin
/access/group/grafana/admin
/access/group/prometheus/viewer
/access/group/n8n/admin
/access/group/traefik/admin
/access/group/immich/admin
/access/group/navidrome/admin
/access/group/asf/admin
/access/group/kubevela/admin
/access/group/influxdb/admin
```

---

## 8. 実装チェックリスト

- [ ] **Keycloak 設定**
  - [ ] `/access/group/<app>/<role>` グループ作成
  - [ ] Client scope に groups mapper 追加
  - [ ] suzutan にグループ割り当て
- [ ] **Pomerium 設定**
  - [ ] 全 ingress-pomerium.yaml を更新
- [ ] **Grafana 設定**
  - [ ] role_attribute_path を更新
- [ ] **動作確認**
  - [ ] suzutan で各サービスにアクセス可能
  - [ ] suzutan で Keycloak Admin アクセス不可
  - [ ] guest で Immich/Navidrome のみ可能
