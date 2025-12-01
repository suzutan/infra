# Task: ArgoCD GitHub Commit Status 問題の調査と修正

## Status: COMPLETED
## Started: 2025-12-01T13:38:00+09:00
## Completed: 2025-12-01T14:10:00+09:00

## Objective
ArgoCD による GitHub commit status が更新されない問題を調査し、修正する

## Summary
ArgoCD Notifications が GitHub commit status を送信できない複数の問題を特定し、修正した。

## Completed Steps
- [x] ArgoCD Notifications Controller のログ調査
- [x] Helm chart の Secret 競合問題を修正（notifications.secret.create: false）
- [x] シークレットキー名の形式を修正（ドットからハイフンへ）
- [x] ConfigMap のシークレット参照形式を修正
- [x] GitHub App Installation ID を更新（org から個人アカウントへの移転後）
- [x] GitHub コミットステータスの動作確認

## Root Causes Found

### 1. Helm Chart Secret 競合
- Helm chart がデフォルトで空の Secret を作成
- 1Password Operator が作成する Secret と競合

### 2. シークレットキー名の形式
- 1Password フィールド名に `.`（ドット）が含まれていた
- ArgoCD Notifications はドットを含むキー名を正しく解析できない

### 3. ConfigMap のシークレット参照形式
- `$secret-name:key` 形式は不正
- 正しい形式は `$key-name`

### 4. GitHub App Installation ID
- GitHub App を組織から個人アカウントに移転
- Installation ID が変更されていた（34948504 → 97400999）

## Modified Files
- `freesia/manifests/argocd/values.yaml` - notifications.secret.create: false 追加
- `freesia/manifests/argocd/patch/cm-argocd-notifications-cm.yaml` - シークレット参照形式修正
- 1Password: argocd-notifications-secret のフィールド名変更

## Commits
- `375d0da` - (previous)
- `e371233` - chore: enable debug logging for argocd notifications
- `aa5cf46` - chore: test notification trigger
- `e28df1d` - chore: cleanup notification debug config

## Verification
- GitHub commit status `CD/argocd: success` が正しく投稿されることを確認
- Discord webhook も正常に動作

## Notes
- ArgoCD Notifications は `operationState.syncResult.revision` を使用して GitHub status を送信
- Reconciliation だけでは operationState は更新されない
- 各 Application に対して Sync 操作が実行された際にステータスが送信される
