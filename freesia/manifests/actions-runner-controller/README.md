# Actions Runner Controller

このディレクトリは、Actions Runner Controller (ARC) v2のコントローラーのみをデプロイする設定を含んでいます。

## 概要

Actions Runner Controller v2は、GitHub ActionsのSelf-hosted Runnerを管理するKubernetesコントローラーです。この設定では、コントローラーのみをインストールし、実際のRunnerは別途設定します。

## コンポーネント

- **gha-runner-scale-set-controller**: ARCのコントローラー部分
  - RunnerのライフサイクルとオートスケーリングCRDを管理
  - GitHub認証は不要（Runnerインストール時に必要）

## 使用方法

### 1. コントローラーのデプロイ

ArgoCDが自動的にデプロイします。手動でデプロイする場合：

```bash
kubectl apply -k freesia/manifests/actions-runner-controller/
```

### 2. Runnerのデプロイ

Runnerは`gha-runner-scale-set` Helm chartを使用して別途デプロイする必要があります。その際に：

1. GitHub Appの作成
2. 1Passwordへの認証情報の登録
3. Runner用のHelmリリースの作成

が必要です。

## バージョン情報

- Controller Chart: `gha-runner-scale-set-controller` v0.12.1

## 参考

- [Actions Runner Controller Documentation](https://github.com/actions/actions-runner-controller)
- [Quickstart Guide](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller)