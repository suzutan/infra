# Current Task

## Metadata
- **Task ID:** TASK-20251201-1200
- **Started:** 2025-12-01 12:00
- **Last Updated:** 2025-12-01 12:30
- **Status:** in_progress

## Request
argocdがトラックしているgithub repositoryのmasterブランチに更新があった際、github webhookからargocdを叩いてリアルタイムに同期させたい。設定を修正して

## Objective
GitHub Webhook を設定して、master ブランチへの push 時に ArgoCD がリアルタイムで同期するようにする

## Context
- ArgoCD は `argocd.harvestasya.org` で稼働中
- Cloudflare Tunnel 経由で `*.harvestasya.org` は外部公開済み
- 1Password Operator で secrets を管理
- `argocd-custom-secret` に `webhook.github.secret` は既に登録済み
- ArgoCD は `argocd-secret` という名前の Secret から webhook secret を読み取る仕様

## Plan
### Phase 1: 調査
- [x] 現在の ArgoCD 設定を確認
- [x] Cloudflare Tunnel の設定を確認

### Phase 2: 設定変更
- [x] IngressRoute に entryPoints を追加
- [x] values.yaml で createSecret: false を設定
- [x] OnePasswordItem で argocd-secret を作成

### Phase 3: ユーザー作業説明
- [ ] 1Password 設定の確認
- [ ] GitHub Webhook 設定手順を説明

## Progress Log
### 2025-12-01 12:05
- 現在の ArgoCD 設定を確認
- ingressroute.yaml に entryPoints が未設定であることを発見

### 2025-12-01 12:10
- ingressroute.yaml に entryPoints (websecure) と TLS 設定を追加
- values.yaml に configs.secret.createSecret: false を追加

### 2025-12-01 12:15
- secret-argocd-secret.yaml を新規作成（OnePasswordItem）
- 当初は新しい 1Password アイテムを参照するよう設定

### 2025-12-01 12:25
- ユーザーから「argocd-custom-secret に既に webhook.github.secret がある」との情報
- 同じ 1Password アイテムを参照するよう修正

### 2025-12-01 12:30
- ユーザーから「新しい Secret は不要では」との指摘
- ArgoCD の仕様（argocd-secret から読み取る）を説明

## Modified Files
| File | Action | Status |
|------|--------|--------|
| freesia/manifests/argocd/ingressroute.yaml | Modified | Done |
| freesia/manifests/argocd/values.yaml | Modified | Done |
| freesia/manifests/argocd/kustomization.yaml | Modified | Done |
| freesia/manifests/argocd/secret-argocd-secret.yaml | Created | Done |

## Decisions Made
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| 同じ 1Password アイテムから2つの Secret を作成 | ArgoCD は argocd-secret から webhook secret を読む仕様 | argocd-custom-secret を argocd-secret にリネーム（既存参照が壊れる） |
| server.secretkey は省略 | 必須ではなく、ArgoCD が自動生成する | 明示的に設定（過剰） |

## Blockers / Open Questions
- [x] argocd-custom-secret に webhook.github.secret があるなら新規 Secret は不要？ → ArgoCD の仕様上、argocd-secret という名前が必要

## Next Steps
1. 変更内容の最終確認
2. GitHub Webhook 設定手順を説明
3. コミット（ユーザー承認後）

## Notes
- 同じ 1Password アイテムを参照する2つの OnePasswordItem により、2つの Kubernetes Secret が作成される
- argocd-custom-secret: OIDC 設定用（argocd-cm から参照）
- argocd-secret: webhook secret 用（ArgoCD が直接読む）
