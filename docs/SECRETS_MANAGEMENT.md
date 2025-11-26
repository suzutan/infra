# Secrets Management

このドキュメントは、HomeLab環境のシークレット管理方法を説明します。

## 概要

シークレット管理には **1Password Operator** を使用しています。すべてのシークレットは1Password Vaultで一元管理され、Kubernetesクラスタに自動同期されます。

```
┌─────────────────────────────────────────────────────────────────┐
│                    1Password Integration                         │
│                                                                  │
│  ┌─────────────────┐                                            │
│  │   1Password     │                                            │
│  │     Vault       │  vaults/5mixaulvwor6zfvbfmtqlksdy4/        │
│  └────────┬────────┘                                            │
│           │                                                      │
│           │ 1Password Connect API                                │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │   1Password     │  onepassword namespace                      │
│  │   Operator      │  Helm v2.0.5                                │
│  └────────┬────────┘                                            │
│           │                                                      │
│           │ Watch OnePasswordItem CRD                            │
│           ▼                                                      │
│  ┌─────────────────┐     ┌─────────────────┐                    │
│  │ OnePasswordItem │────▶│   Kubernetes    │                    │
│  │     CRD         │     │    Secret       │                    │
│  └─────────────────┘     └─────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
```

## OnePasswordItem の使用方法

### 基本的な定義

```yaml
apiVersion: onepassword.com/v1
kind: OnePasswordItem
metadata:
  name: <secret-name>
  namespace: <namespace>
spec:
  itemPath: "vaults/5mixaulvwor6zfvbfmtqlksdy4/items/<item-name>"
```

### 命名規則

- **Secret名**: `secret-` プレフィックスを使用
- **OnePasswordItem名**: アプリケーション名 + 用途

例:
- `secret-authentik-custom` → Authentik設定
- `secret-immich-env` → Immich環境変数
- `secret-grafana` → Grafana管理者認証情報

## 管理されているシークレット一覧

### 認証・認可

| OnePasswordItem | 名前空間 | 用途 |
|-----------------|---------|------|
| authentik-custom | authentik | Authentik設定 (SECRET_KEY等) |
| authentik-postgresql-custom | authentik | PostgreSQL認証情報 |
| authentik-redis-custom | authentik | Redis認証情報 |
| argocd-custom-secret | argocd | ArgoCD OIDC設定 |

### アプリケーション

| OnePasswordItem | 名前空間 | 用途 |
|-----------------|---------|------|
| immich-database-app | immich | Immich DB認証情報 |
| immich-valkey | immich | Valkey認証情報 |
| n8n-secret-env | n8n | n8n環境変数 |
| n8n-pg-app | n8n | n8n DB認証情報 |

### インフラストラクチャ

| OnePasswordItem | 名前空間 | 用途 |
|-----------------|---------|------|
| cert-manager-cloudflare | cert-manager | Cloudflare APIトークン |
| ddns-cloudflare | ddns | DDNS用Cloudflareトークン |
| grafana-secret | temporis | Grafana管理者パスワード |
| influxdb2-auth | temporis | InfluxDB認証情報 |

### その他

| OnePasswordItem | 名前空間 | 用途 |
|-----------------|---------|------|
| hsr-auto-claimer-secret | hsr-auto-claimer | 自動実行用トークン |

## シークレット参照パターン

### 環境変数として参照

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
spec:
  template:
    spec:
      containers:
        - name: app
          envFrom:
            - secretRef:
                name: secret-example-env
```

### 個別キーの参照

```yaml
env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: secret-database
        key: password
```

### ボリュームマウント

```yaml
volumes:
  - name: secret-volume
    secret:
      secretName: secret-tls-cert
volumeMounts:
  - name: secret-volume
    mountPath: /etc/ssl/certs
    readOnly: true
```

## 新しいシークレットの追加手順

### 1. 1Password Vaultにアイテム作成

1Password Vault (`vaults/5mixaulvwor6zfvbfmtqlksdy4/`) に新しいアイテムを作成します。

**注意事項:**
- アイテム名は一意であること
- フィールド名はKubernetesのSecret keyとして使用される

### 2. OnePasswordItem CRD作成

```yaml
# onepassworditem.yaml
apiVersion: onepassword.com/v1
kind: OnePasswordItem
metadata:
  name: <application>-secret
  namespace: <namespace>
spec:
  itemPath: "vaults/5mixaulvwor6zfvbfmtqlksdy4/items/<item-name>"
```

### 3. Kustomizationに追加

```yaml
# kustomization.yaml
resources:
  - namespace.yaml
  - deployment.yaml
  - onepassworditem.yaml  # 追加
```

### 4. アプリケーションから参照

Deployment/StatefulSet等でSecretを参照します。

## 自動リスタート

1Password Operatorは、Secretが更新された際にPodを自動的にリスタートする機能があります。

### アノテーション設定

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
  annotations:
    operator.1password.io/auto-restart: "true"
spec:
  # ...
```

## 証明書管理

TLS証明書は **cert-manager** で管理されています。

### ワイルドカード証明書

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: harvestasya-wildcard
  namespace: cert-manager
spec:
  secretName: harvestasya-wildcard-tls
  dnsNames:
    - "*.harvestasya.org"
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
```

### 自己署名CA

内部用途の証明書には自己署名CAを使用できます。

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: harvestasya-root-ca
spec:
  ca:
    secretName: harvestasya-root-ca
```

## セキュリティベストプラクティス

### 禁止事項

1. **直接コミット禁止**: シークレット値をリポジトリに直接コミットしない
2. **プレーンテキスト禁止**: base64エンコードされていてもSecret YAMLを直接作成しない
3. **共有禁止**: 1Password以外の方法でシークレットを共有しない

### 推奨事項

1. **OnePasswordItem使用**: すべてのシークレットは1Password経由で管理
2. **最小権限**: 必要なシークレットのみをPodにマウント
3. **ローテーション**: 定期的なシークレットローテーションを実施
4. **監査**: 1Passwordの監査ログを定期的に確認

## トラブルシューティング

### Secretが作成されない

```bash
# 1Password Operatorのログ確認
kubectl logs -n onepassword -l app=onepassword-connect

# OnePasswordItemのステータス確認
kubectl get onepassworditem -n <namespace> -o yaml
```

### Secretが更新されない

```bash
# Operatorの再起動
kubectl rollout restart deployment -n onepassword onepassword-connect

# OnePasswordItemの再作成
kubectl delete onepassworditem <name> -n <namespace>
kubectl apply -f onepassworditem.yaml
```

## 関連ドキュメント

- [1Password Kubernetes Operator](https://developer.1password.com/docs/k8s/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
