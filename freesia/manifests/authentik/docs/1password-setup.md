# 1Password OIDC シークレット設定ガイド

## 概要

Authentik BlueprintでOIDCアプリケーションを管理する際の1Passwordシークレット設定方法について説明します。

## 1Passwordアイテムの作成

### 1. 1Passwordにログイン

1Password管理画面にログインし、`k8s`ボールトを選択します。

### 2. 新規アイテムの作成

`authentik-oidc-secrets`という名前で新しいアイテムを作成します。

- **タイプ**: ログイン
- **タイトル**: `authentik-oidc-secrets`
- **ボールト**: `k8s`

### 3. フィールドの追加

各OIDCアプリケーション用のフィールドを追加します：

#### Example App
- **フィールド名**: `example-app`
- **タイプ**: パスワード
- **値**: ランダムな文字列を生成（例: 32文字以上）

#### ArgoCD
- **フィールド名**: `argocd`
- **タイプ**: パスワード
- **値**: 既存のArgoCDクライアントシークレット、または新規生成

#### Grafana
- **フィールド名**: `grafana`
- **タイプ**: パスワード
- **値**: ランダムな文字列を生成

### 4. 新しいアプリの追加時

新しいOIDCアプリケーションを追加する際は、以下の手順で行います：

1. 同じ`authentik-oidc-secrets`アイテムに新しいフィールドを追加
2. フィールド名はBlueprintで定義した`client_id`と同じにする
3. セキュアなランダム文字列を値として設定

## セキュリティベストプラクティス

### シークレットの生成

- 最低32文字以上の長さを推奨
- 英数字と特殊文字を含める
- 1Passwordのパスワード生成機能を使用

### シークレットのローテーション

定期的にシークレットをローテーションする場合：

1. 1Passwordで新しいシークレットを生成
2. フィールドの値を更新
3. Kubernetes上のPodを再起動して変更を反映

```bash
kubectl rollout restart deployment -n authentik authentik-server authentik-worker
```

## トラブルシューティング

### シークレットが反映されない場合

1. OnePasswordItemのステータスを確認：
   ```bash
   kubectl describe onepassworditem -n authentik secret-authentik-oidc-apps
   ```

2. 生成されたSecretを確認：
   ```bash
   kubectl get secret -n authentik secret-authentik-oidc-apps -o yaml
   ```

3. 1Password Operatorのログを確認：
   ```bash
   kubectl logs -n onepassword-operator deployment/onepassword-operator
   ```

### フィールド名の注意事項

- フィールド名は正確にBlueprintの`client_id`と一致する必要があります
- 大文字小文字を区別します
- スペースやハイフンの使用に注意

## 参考情報

- [1Password Operator Documentation](https://github.com/1Password/onepassword-operator)
- [Authentik Blueprint Documentation](https://docs.goauthentik.io/developer-docs/blueprints/)