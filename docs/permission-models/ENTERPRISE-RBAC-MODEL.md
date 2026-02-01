# Enterprise RBAC Permission Model

> **Status**: Reference
> **Version**: 1.0.0
> **Date**: 2026-02-02

一般的な企業で実装される標準的なロールベースアクセス制御（RBAC）モデル。

---

## 概要

```
┌─────────────────────────────────────────────────────────────────┐
│                     RBAC Architecture                           │
│                                                                 │
│   User → Role → Permission → Resource                          │
│                                                                 │
│   ユーザーにロールを割り当て、                                   │
│   ロールに紐づく権限でリソースへのアクセスを制御                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Roles（ロール）

### 基本ロール

| Role | 説明 | 対象者 |
|------|------|--------|
| **admin** | 全システム管理者 | インフラ責任者 |
| **platform-engineer** | プラットフォーム管理者 | SRE/Platform チーム |
| **developer** | 開発者 | 開発チーム |
| **operator** | 運用担当者 | 運用チーム |
| **viewer** | 閲覧者 | 関係者全般 |
| **guest** | ゲスト | 外部協力者 |

### ロール階層

```
admin
  ├── platform-engineer
  │     ├── developer
  │     │     └── viewer
  │     └── operator
  │           └── viewer
  └── security-admin
        └── auditor
              └── viewer
```

---

## 2. Permissions（権限）

### 権限マトリクス

| 権限 | admin | platform-engineer | developer | operator | viewer |
|------|:-----:|:-----------------:|:---------:|:--------:|:------:|
| **インフラ変更** | ✓ | ✓ | - | - | - |
| **デプロイ実行** | ✓ | ✓ | ✓ | ✓ | - |
| **設定変更** | ✓ | ✓ | ✓ | - | - |
| **ログ閲覧** | ✓ | ✓ | ✓ | ✓ | ✓ |
| **メトリクス閲覧** | ✓ | ✓ | ✓ | ✓ | ✓ |
| **シークレット閲覧** | ✓ | ✓ | - | - | - |
| **ユーザー管理** | ✓ | - | - | - | - |
| **監査ログ** | ✓ | ✓ | - | - | - |

---

## 3. Resource Groups（リソースグループ）

| Group | 含まれるリソース |
|-------|------------------|
| **infrastructure** | ArgoCD, Terraform, Kubernetes |
| **monitoring** | Prometheus, Grafana, Alertmanager |
| **security** | Keycloak, Pomerium, Vault |
| **development** | CI/CD, Registry, Dev Tools |
| **applications** | 業務アプリケーション |

---

## 4. Keycloak グループ構造

```
/roles
  /admin              → role.admin
  /platform-engineer  → role.platform-engineer
  /developer          → role.developer
  /operator           → role.operator
  /viewer             → role.viewer
  /guest              → role.guest

/teams
  /infrastructure     → team.infrastructure
  /development        → team.development
  /operations         → team.operations
  /security           → team.security

/projects
  /project-a          → project.project-a
  /project-b          → project.project-b
```

---

## 5. サービス別アクセス制御

| サービス | 閲覧 | 操作 | 管理 |
|----------|------|------|------|
| **Grafana** | viewer | operator | platform-engineer |
| **Prometheus** | viewer | operator | platform-engineer |
| **ArgoCD** | viewer | developer | platform-engineer |
| **Keycloak** | - | - | admin |
| **n8n** | viewer | developer | platform-engineer |
| **Immich** | viewer | viewer | admin |

---

## 6. 一時権限昇格

### 方式

```yaml
# Just-In-Time (JIT) Access
elevation:
  method: request-approval
  approvers:
    - role: admin
    - role: platform-engineer
  max_duration: 4h
  audit: required
```

### フロー

```
1. ユーザーが権限昇格をリクエスト
     ↓
2. 承認者に通知
     ↓
3. 承認者がレビュー・承認
     ↓
4. 一時的にロールを付与
     ↓
5. 有効期限後に自動失効
     ↓
6. 監査ログに記録
```

---

## 7. Pomerium Policy

```yaml
routes:
  # Grafana - viewer 以上
  - from: https://grafana.example.com
    to: http://grafana.monitoring.svc.cluster.local:3000
    policy:
      - allow:
          or:
            - groups:
                has: "role.viewer"
            - groups:
                has: "role.operator"
            - groups:
                has: "role.developer"
            - groups:
                has: "role.platform-engineer"
            - groups:
                has: "role.admin"

  # ArgoCD 閲覧 - viewer 以上
  - from: https://argocd.example.com
    to: http://argocd-server.argocd.svc.cluster.local
    policy:
      - allow:
          or:
            - groups:
                has: "role.viewer"
            - groups:
                has: "role.developer"
            - groups:
                has: "role.platform-engineer"
            - groups:
                has: "role.admin"

  # ArgoCD Sync - developer 以上
  - from: https://argocd.example.com
    to: http://argocd-server.argocd.svc.cluster.local
    policy:
      - allow:
          and:
            - or:
                - groups:
                    has: "role.developer"
                - groups:
                    has: "role.platform-engineer"
                - groups:
                    has: "role.admin"
            - http_path:
                regex: "^/api/v1/applications/.*/sync$"
            - http_method:
                is: "POST"

  # Keycloak Admin - admin のみ
  - from: https://auth-admin.example.com
    to: http://keycloak.keycloak.svc.cluster.local:8080
    policy:
      - allow:
          groups:
            has: "role.admin"
```

---

## 8. 通知テンプレート

### 権限リクエスト

```
📋 Access Request
━━━━━━━━━━━━━━━━
User: john.doe@example.com
Requested Role: platform-engineer
Duration: 4 hours
Reason: "Emergency infrastructure maintenance"

[Approve] [Deny]
```

### 承認完了

```
✅ Access Granted
━━━━━━━━━━━━━━━━
User: john.doe@example.com
Role: platform-engineer
Expires: 2026-02-02 23:00:00 UTC
Approved by: admin@example.com
```

### 権限失効

```
🔒 Access Expired
━━━━━━━━━━━━━━━━
User: john.doe@example.com
Role: platform-engineer
Duration: 4h
Status: Automatically revoked
```

---

## 9. 運用プロファイル例

### 一般開発者

```yaml
user: john.doe@example.com
roles:
  - developer
teams:
  - development
projects:
  - project-a
```

**できること:**
- Grafana/Prometheus 閲覧
- ArgoCD で自分のプロジェクトをデプロイ
- n8n でワークフロー作成

**できないこと:**
- 他プロジェクトへのアクセス
- インフラ設定変更
- ユーザー管理

### Platform Engineer

```yaml
user: jane.smith@example.com
roles:
  - platform-engineer
teams:
  - infrastructure
projects:
  - all
```

**できること:**
- 全プロジェクトのデプロイ
- インフラ設定変更
- 監査ログ閲覧

**できないこと:**
- ユーザー管理
- セキュリティ設定変更

---

## 10. セキュリティ原則

### 最小権限の原則 (Least Privilege)

```
必要最小限の権限のみを付与する
- 業務に必要な権限だけ
- 期間限定の権限昇格
- 定期的な権限レビュー
```

### 職務分離 (Separation of Duties)

```
重要な操作は複数人のチェックを必要とする
- 本番デプロイには承認が必要
- セキュリティ設定変更は別途承認
- 監査担当と運用担当は分離
```

### 監査可能性 (Auditability)

```
すべてのアクセスは記録される
- 誰が、いつ、何をしたか
- 権限変更の履歴
- 異常アクセスの検知
```

---

## 11. 比較: Enterprise vs Harvestasha

| 観点 | Enterprise RBAC | Harvestasha |
|------|-----------------|-------------|
| **命名** | 機能的 (admin, developer) | 世界観ベース (SH_SERVER, EXEC_FLIP) |
| **構造** | Role → Permission | Level × Server × EXEC |
| **昇格** | 承認ワークフロー | 自己昇格 + 監査 |
| **雰囲気** | ビジネスライク | SF/ディストピア |
| **学習コスト** | 低い | 高い（世界観の理解が必要） |
| **モチベーション** | 普通 | 高い（ロールプレイ要素） |
| **適用場面** | 企業、チーム運用 | 個人、趣味プロジェクト |

---

## 12. ツール連携

### 一般的なエンタープライズツール

| カテゴリ | ツール |
|----------|--------|
| **IdP** | Okta, Azure AD, Keycloak |
| **PAM** | HashiCorp Vault, CyberArk |
| **JIT Access** | Teleport, Boundary, Opal |
| **Audit** | Splunk, Datadog, CloudTrail |
| **Policy** | OPA, Kyverno, Pomerium |
