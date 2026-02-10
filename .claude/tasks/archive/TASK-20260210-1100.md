# Task: 1Password Operator → External Secrets Operator 移行 (Phase 1-2)

## 概要
1Password Operator から External Secrets Operator (ESO) への移行を Phase 1-2 のスコープで実施。

## 状態: 完了

## スコープ
- Phase 1: ESO 基盤構築
- Phase 2: 低リスクアプリで検証 (ddns, hsr-auto-claimer, airq-exporter, remo-exporter)

## 進捗

### Phase 1: ESO 基盤構築
- [x] ディレクトリ・ファイル作成
  - [x] k8s/manifests/external-secrets/namespace.yaml
  - [x] k8s/manifests/external-secrets/kustomization.yaml
  - [x] k8s/manifests/external-secrets/values.yaml
  - [x] k8s/manifests/external-secrets/cluster-secret-store.yaml
- [x] ArgoCD Application 追加 (k8s/manifests/argocd-apps/external-secrets.yaml)
- [x] push して ArgoCD 同期確認

### Phase 2: 低リスクアプリで検証
- [x] ddns: ExternalSecret 作成 (OnePasswordItem はコメントアウト)
- [x] hsr-auto-claimer: ExternalSecret 作成 (OnePasswordItem はコメントアウト)
- [x] airq-exporter: ExternalSecret 作成 (OnePasswordItem はコメントアウト)
- [x] remo-exporter: ExternalSecret 作成 (OnePasswordItem はコメントアウト)

## Modified Files
- k8s/manifests/external-secrets/namespace.yaml (新規)
- k8s/manifests/external-secrets/kustomization.yaml (新規)
- k8s/manifests/external-secrets/values.yaml (新規)
- k8s/manifests/external-secrets/cluster-secret-store.yaml (新規)
- k8s/manifests/argocd-apps/external-secrets.yaml (新規)
- k8s/manifests/argocd-apps/kustomization.yaml (external-secrets 追加)
- k8s/manifests/ddns/external-secret.yaml (新規)
- k8s/manifests/ddns/kustomization.yaml (ExternalSecret 追加、OnePasswordItem コメントアウト)
- k8s/manifests/hsr-auto-claimer/external-secret.yaml (新規)
- k8s/manifests/hsr-auto-claimer/kustomization.yaml (ExternalSecret 追加、OnePasswordItem コメントアウト)
- k8s/manifests/temporis/airq-exporter/external-secret.yaml (新規)
- k8s/manifests/temporis/airq-exporter/kustomization.yaml (ExternalSecret 追加、OnePasswordItem コメントアウト)
- k8s/manifests/temporis/remo-exporter/external-secret.yaml (新規)
- k8s/manifests/temporis/remo-exporter/kustomization.yaml (ExternalSecret 追加、OnePasswordItem コメントアウト)

## Commit
- d470686: feat(secrets): add External Secrets Operator and migrate Phase 2 apps

## Decisions
- ClusterSecretStore を採用 (全アイテムが同一 Vault)
- 1Password Connect は継続利用
- Secret 名の互換性維持
- ESO Helm Chart version: 0.12.1
- OnePasswordItem ファイルは削除せずコメントアウト (ロールバック容易化)

## Next Steps (手動確認)
1. ArgoCD で external-secrets Application が Healthy になることを確認
2. ClusterSecretStore の接続確認: `kubectl get clustersecretstore onepassword-connect -o yaml`
3. ExternalSecret の同期確認: `kubectl get externalsecret -A`
4. 各 namespace で Secret が正しく作成されていることを確認
5. 動作確認後、OnePasswordItem ファイルを削除
6. Phase 3 以降の移行を継続
