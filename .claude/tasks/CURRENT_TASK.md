# Current Task

## Metadata
- **Task ID:** TASK-20251201-1330
- **Started:** 2025-12-01 13:30
- **Last Updated:** 2025-12-01 13:30
- **Status:** in_progress

## Request
secretを目的別でちゃんと分離したい。どのキーをどのsecretに分離したら良いか調べて

## Objective
現在の argocd-custom-secret のキーを分析し、目的別に分離する最適な構成を提案する

## Context
- 現在、同じ 1Password アイテムから3つの Kubernetes Secret を作成
- argocd-custom-secret, argocd-secret, argocd-notifications-secret

## Plan
### Phase 1: 調査
- [x] 現在の secret キー一覧を確認
- [x] 各キーの使用箇所を特定
- [x] 最適な分離案を提案

### Phase 2: 実装
- [x] OnePasswordItem リソースを更新
- [x] ConfigMap の参照を更新
- [x] 不要なリソースを削除

## Progress Log
### 2025-12-01 13:35
- secret キー分析完了
- 3つの 1Password アイテムに分離する案を決定

### 2025-12-01 13:40
- secret-argocd-oidc-secret.yaml を作成
- secret-argocd-notifications-secret.yaml を更新（アイテム名変更）
- secret-argocd-secret.yaml を更新（アイテム名変更）
- cm-argocd-cm.yaml の参照を argocd-oidc-secret に変更
- secret-argocd-custom-secret.yaml を削除

## Modified Files
| File | Action | Status |
|------|--------|--------|
| freesia/manifests/argocd/secret-argocd-oidc-secret.yaml | Created | Done |
| freesia/manifests/argocd/secret-argocd-notifications-secret.yaml | Modified | Done |
| freesia/manifests/argocd/secret-argocd-secret.yaml | Modified | Done |
| freesia/manifests/argocd/kustomization.yaml | Modified | Done |
| freesia/manifests/argocd/patch/cm-argocd-cm.yaml | Modified | Done |
| freesia/manifests/argocd/secret-argocd-custom-secret.yaml | Deleted | Done |

## Decisions Made
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| 3つの 1Password アイテムに分離 | 目的別に分離し、最小権限の原則に従う | 現状維持（複製が多い） |

## Blockers / Open Questions
- ユーザーが 1Password に新しいアイテムを作成する必要あり

## Next Steps
1. 1Password にアイテムを作成
2. コミット & プッシュ

## Notes
### 必要な 1Password アイテム

**argocd-oidc** (OIDC 認証用)
- authentik.client-id
- authentik.client-secret

**argocd-notifications** (通知用)
- github.app-id
- github.installation-id
- github.private-key
- discord.webhook-url

**argocd-webhook** (Webhook用)
- webhook.github.secret
