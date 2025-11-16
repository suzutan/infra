# Immich PostgreSQL移行手順: Bitnami Helm → CloudNativePG

このドキュメントは、ImmichのPostgreSQLをBitnami HelmチャートからCloudNativePGに切り替える手順を説明します。

## 変更内容

- **旧構成**: Bitnami PostgreSQL Helmチャート (pgvector拡張)
- **新構成**: CloudNativePG Operator (vchord拡張)
- **DB_VECTOR_EXTENSION**: `pgvector` → `vchord`
- **DB_HOSTNAME**: `postgresql` → `immich-database-rw`

## 前提条件

- CloudNativePG Operatorがクラスタにインストールされていること
- 既存のImmichデータのバックアップを取得していること

## 移行手順

### 1. データベースのバックアップ

```bash
# 現在のPodを確認
kubectl get pods -n immich

# PostgreSQLからデータをダンプ
kubectl exec -n immich postgresql-0 -- pg_dump -U immich immich > immich_backup.sql
```

### 2. 既存のImmichサーバーを停止

```bash
kubectl scale deployment immich-server -n immich --replicas=0
```

### 3. CloudNativePGクラスタをデプロイ

変更をコミットしてArgoCD経由でデプロイするか、手動で適用:

```bash
# マニフェストを適用
kubectl apply -f freesia/manifests/immich/cloudnative-pg.yaml

# Clusterの作成を確認
kubectl get cluster -n immich

# Podの起動を待機
kubectl wait --for=condition=Ready pod -l cnpg.io/cluster=immich-database -n immich --timeout=300s
```

### 4. データベースのリストア

```bash
# CloudNativePG Clusterのプライマリポッドを取得
CNPG_POD=$(kubectl get pod -n immich -l cnpg.io/cluster=immich-database,role=primary -o jsonpath='{.items[0].metadata.name}')

# データをリストア
cat immich_backup.sql | kubectl exec -i -n immich $CNPG_POD -- psql -U immich -d immich
```

### 5. Immichサーバーを起動

```bash
# ArgoCD経由の場合は、変更をpushしてsync
# 手動の場合:
kubectl apply -f freesia/manifests/immich/server-deployment.yaml

# サーバーの起動を確認
kubectl get pods -n immich -l app.kubernetes.io/name=immich-server
kubectl logs -n immich -l app.kubernetes.io/name=immich-server --tail=50
```

### 6. 動作確認

```bash
# Immichサーバーのログを確認
kubectl logs -n immich -l app.kubernetes.io/name=immich-server

# データベース接続を確認
kubectl exec -n immich $CNPG_POD -- psql -U immich -d immich -c "\dx"

# 期待される拡張が表示されること:
# - vchord
# - earthdistance
```

### 7. 旧PostgreSQL Helmリリースを削除

動作確認が完了したら、旧PostgreSQLを削除:

```bash
# Helm releaseを削除
helm uninstall postgresql -n immich

# PVCを削除（データを完全に削除する場合）
kubectl delete pvc -n immich data-postgresql-0
```

## ロールバック手順

問題が発生した場合のロールバック:

```bash
# Immichサーバーを停止
kubectl scale deployment immich-server -n immich --replicas=0

# CloudNativePGクラスタを削除
kubectl delete cluster immich-database -n immich

# Gitで変更を元に戻す
git revert HEAD

# ArgoCD経由でsyncするか、手動で旧構成を適用
```

## 確認項目

- [ ] CloudNativePG Operatorがインストールされている
- [ ] 既存データベースのバックアップを取得
- [ ] CloudNativePG Clusterが正常に起動
- [ ] vchord拡張がインストールされている
- [ ] Immichサーバーがデータベースに接続できる
- [ ] アプリケーションの動作確認（写真のアップロード、検索など）
- [ ] 旧PostgreSQLリソースを削除

## トラブルシューティング

### Clusterが起動しない

```bash
# Clusterのステータスを確認
kubectl describe cluster immich-database -n immich

# Operatorのログを確認
kubectl logs -n cnpg-system deployment/cnpg-controller-manager
```

### データベース接続エラー

```bash
# Serviceが作成されているか確認
kubectl get svc -n immich | grep immich-database

# 期待されるService:
# - immich-database-rw (read-write)
# - immich-database-ro (read-only)
# - immich-database-r (read)
```

### vchord拡張のエラー

```bash
# コンテナイメージを確認
kubectl get cluster immich-database -n immich -o jsonpath='{.spec.imageName}'

# 期待されるイメージ: ghcr.io/tensorchord/cloudnative-vectorchord:16.9-0.4.3
```

## 参考リンク

- [CloudNativePG公式ドキュメント](https://cloudnative-pg.io/)
- [Immich公式ドキュメント](https://immich.app/docs/)
- [immich-charts CloudNativePG設定](https://github.com/immich-app/immich-charts/blob/main/local/cloudnative-pg.yaml)
