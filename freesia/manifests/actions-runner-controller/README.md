# Actions Runner Controller

このディレクトリは GitHub Actions Runner Controller (ARC) v2 のコントローラーをデプロイするための設定です。

## 概要

Actions Runner Controller v2 は、GitHub Actions のセルフホステッドランナーを Kubernetes 上で動的に管理するためのコントローラーです。

このマニフェストでは、`gha-runner-scale-set-controller` Helm chart のみをインストールします。

## 構成

- **Namespace**: `actions-runner-system`
- **Helm Chart**: `gha-runner-scale-set-controller` v0.11.0
- **ソース**: `oci://ghcr.io/actions/actions-runner-controller-charts`

## セットアップ

このコントローラーは ArgoCD によって自動的にデプロイされます。

## Runner Scale Set の追加

実際のランナーを追加する場合は、別途 Runner Scale Set を設定する必要があります。詳細は以下のドキュメントを参照してください：

- [GitHub Actions Runner Controller Quickstart](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller)
- [Deploying runner scale sets](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/deploying-runner-scale-sets-with-actions-runner-controller)