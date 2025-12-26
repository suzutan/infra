# Task Completion Checklist

タスク完了時に実行すべき項目のチェックリストです。

## 必須項目

### 1. YAML フォーマットチェック

すべての YAML ファイルが正しくフォーマットされているか確認:

```bash
task yamlfmt
```

**エラーがある場合:**
```bash
# フォーマットを自動適用
find ./ -name "*.yaml" | grep -v "charts/" | xargs yamlfmt
```

### 2. Kubernetes Manifest のバリデーション

変更した manifest が構文的に正しいか確認:

```bash
kubectl apply --dry-run=client -f <manifest-file>
```

または Kustomize を使用している場合:

```bash
kustomize build k8s/manifests/<app-name> | kubectl apply --dry-run=client -f -
```

### 3. Terraform の検証 (Terraform 変更時のみ)

Terraform の変更がある場合は plan を実行:

```bash
cd terraform/<domain-name>
terraform init  # 初回のみ
terraform plan
```

**適用前に確認:**
- plan の出力を確認
- 意図しないリソースの削除がないか
- DNS レコードの変更が正しいか

### 4. Git コミット

Conventional Commits 形式でコミット:

```bash
git add .
git commit -m "<type>: <description>"
```

**Type の選択:**
- `feat:` 新機能追加
- `fix:` バグ修正
- `chore:` 雑務、依存関係更新
- `docs:` ドキュメント
- `refactor:` リファクタリング

## 推奨項目

### 5. ArgoCD 同期状態の確認 (Kubernetes 変更時)

変更後、ArgoCD が正しく同期しているか確認:

```bash
kubectl get applications -n argocd
```

**STATUS が Synced になっているか確認:**
- `OutOfSync`: まだ同期されていない (自動同期待ち)
- `Synced`: 同期完了
- `Unknown` または `Error`: 問題あり

### 6. コミットメッセージの確認

- Conventional Commits 形式に従っているか
- 変更内容が明確に説明されているか
- スコープが適切か (例: `chore(deps):`)

### 7. セキュリティチェック

- **シークレットのコミット禁止**
  - パスワード、API キー、トークンが含まれていないか
  - `.env` ファイルがコミットされていないか
  
- **1Password Operator の使用**
  - シークレットは必ず 1Password Operator 経由で管理

### 8. 命名規則の確認

- Kubernetes リソース名: 小文字 + ハイフン
- ファイル名: kebab-case
- シークレット名: `secret-` プレフィックス

## 変更タイプ別チェックリスト

### 新しい Kubernetes アプリケーション追加時

- [ ] `k8s/manifests/<app-name>/` ディレクトリ作成
- [ ] `namespace.yaml` 作成
- [ ] `kustomization.yaml` 作成
- [ ] 必要なリソース (Deployment, Service など) 作成
- [ ] `k8s/manifests/argocd-apps/<app-name>.yaml` 作成
- [ ] `k8s/manifests/argocd-apps/kustomization.yaml` に追加
- [ ] yamlfmt でフォーマット
- [ ] kubectl dry-run で検証
- [ ] コミットとプッシュ
- [ ] ArgoCD で同期確認

### Kubernetes リソース変更時

- [ ] 変更内容が既存のパターンに従っているか
- [ ] yamlfmt でフォーマット
- [ ] kubectl dry-run で検証
- [ ] コミット
- [ ] ArgoCD で同期確認

### Terraform 変更時

- [ ] `terraform fmt` でフォーマット
- [ ] `terraform validate` で検証
- [ ] `terraform plan` で変更内容確認
- [ ] コミット
- [ ] (必要に応じて) `terraform apply` で適用

### ドキュメント変更時

- [ ] Markdown の構文チェック
- [ ] リンクが正しいか確認
- [ ] コミット

## トラブルシューティング

### yamlfmt エラーが出る場合

```bash
# エラーメッセージを確認
find ./ -name "*.yaml" | grep -v "charts/" | xargs yamlfmt -lint

# 自動修正
find ./ -name "*.yaml" | grep -v "charts/" | xargs yamlfmt
```

### ArgoCD が OutOfSync のまま

```bash
# 手動で同期をトリガー
kubectl -n argocd patch application <app-name> --type merge -p '{"operation":{"initiatedBy":{"username":"manual"},"sync":{"revision":"HEAD"}}}'
```

### Terraform plan が失敗する場合

```bash
# 初期化し直す
terraform init -upgrade

# キャッシュをクリア
rm -rf .terraform
terraform init
```
