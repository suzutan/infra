# Suggested Commands

## 開発ツールのセットアップ

### aqua によるツールインストール
```bash
aqua install
```

すべての必要なツール (kubectl, kustomize, helm, terraform) がインストールされます。

## YAML フォーマット

### フォーマットチェック
```bash
task yamlfmt
```

または直接:
```bash
find ./ -name "*.yaml" | grep -v "charts/" | xargs yamlfmt -lint
```

### フォーマット適用
```bash
find ./ -name "*.yaml" | grep -v "charts/" | xargs yamlfmt
```

## Kubernetes

### Manifest の検証 (dry-run)
```bash
kubectl apply --dry-run=client -f <manifest-file>
```

### Kustomize ビルドの確認
```bash
kustomize build freesia/manifests/<app-name>
```

### ArgoCD による同期状態確認
```bash
kubectl get applications -n argocd
```

### ArgoCD で手動同期
```bash
kubectl -n argocd patch application <app-name> --type merge -p '{"operation":{"initiatedBy":{"username":"manual"},"sync":{"revision":"HEAD"}}}'
```

または ArgoCD CLI:
```bash
argocd app sync <app-name>
```

## Terraform

### 初期化
```bash
cd terraform/<domain-name>
terraform init
```

### プランの確認
```bash
terraform plan
```

### 適用
```bash
terraform apply
```

### Terraform Cloud ログイン
```bash
terraform login
```

## Git コマンド

### ブランチ確認
```bash
git status
git branch
```

### 変更のコミット
```bash
git add .
git commit -m "feat: add new feature"
```

### プッシュ
```bash
git push origin master
```

## macOS (Darwin) 固有の注意点

このプロジェクトは macOS (Darwin) 環境で開発されています。

### ファイル検索
```bash
# find コマンド (BSD 版)
find . -name "*.yaml"

# GNU find と異なる場合があるため注意
```

### grep
```bash
# macOS の grep (BSD 版)
grep -r "pattern" .
```

### その他の一般的なコマンド
```bash
ls -la          # ファイル一覧
cd <directory>  # ディレクトリ移動
cat <file>      # ファイル内容表示
```

## 開発ワークフロー

### 新しいアプリケーションの追加

1. **マニフェストディレクトリ作成**
   ```bash
   mkdir -p freesia/manifests/<app-name>
   ```

2. **必要なファイルを作成**
   - `namespace.yaml`
   - `kustomization.yaml`
   - アプリケーション固有のリソース

3. **ArgoCD Application 作成**
   ```bash
   # freesia/manifests/argocd-apps/<app-name>.yaml を作成
   ```

4. **kustomization.yaml に追加**
   ```bash
   cd freesia/manifests/argocd-apps
   # kustomization.yaml に新しいアプリを追加
   ```

5. **フォーマットチェック**
   ```bash
   task yamlfmt
   ```

6. **コミットとプッシュ**
   ```bash
   git add .
   git commit -m "feat: add <app-name> application"
   git push
   ```

ArgoCD が自動的に変更を検出し、デプロイします。
