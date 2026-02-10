# Kustomize + Helm 互換性チェックリスト

このドキュメントは、Kustomize と Helm のバージョンアップグレード可否を判断するためのチェックリストです。

## 現在の使用バージョン

| ツール | バージョン | 設定ファイル |
|--------|-----------|-------------|
| Kustomize | v5.8.1 | `aqua.yaml` |
| Helm | v3.20.0 | `aqua.yaml` |

## 追跡中の問題

### 1. helmCharts の namespace 回帰バグ ✅ **修正確認済み**

**Issue**: [#6014 - v5.8.0 breaks namespace behaviour in HelmChartInflationGenerator](https://github.com/kubernetes-sigs/kustomize/issues/6014)

**概要**: Kustomize v5.8.0 で、HelmChartInflationGenerator 使用時に namespace がレンダリングされたマニフェストから消失する。v5.7.1 では正常に動作。

**ステータス**:
- Issue #6014 は Open のまま（2026-02-10 時点）
- しかし、**v5.8.1 で実際に修正されていることを確認** ✅
- 関連 PR [#6044](https://github.com/kubernetes-sigs/kustomize/pull/6044) が v5.8.1 に含まれており、namespace 伝播問題を修正

**検証結果（2026-02-10）**:
- テスト環境: 本リポジトリの helmCharts 使用アプリ（traefik, argocd 他 11個）
- 検証バージョン: Kustomize v5.8.1
- 結果: 全リソース（ServiceAccount, Deployment, Service）で namespace フィールドが正常に生成される
- **結論**: v5.8.1 は本番利用可能

### 2. Helm v4 との互換性問題 ✅ **解決済み**

**Issue**: [#6013 - Fix an error with Helm v4](https://github.com/kubernetes-sigs/kustomize/issues/6013) - **Closed**

**PR**: [#6016](https://github.com/kubernetes-sigs/kustomize/pull/6016) - **Merged**

**概要**: Helm v4.0.0 で `-c` フラグが削除されたため、`kustomize build --enable-helm` が失敗する。

**ステータス（2026-02-10）**:
- PR #6016 が v5.8.1 にマージ済み
- Kustomize v5.8.1 は Helm v3 と v4 の両方に対応
- **Helm v4 へのアップグレードが可能**（Kustomize v5.8.1 使用時）

### 3. 元々の namespace 伝播問題（参考）

**Issue**: [#5566 - Kustomize doesn't pass namespace to helmCharts](https://github.com/kubernetes-sigs/kustomize/issues/5566)

**修正PR**: [#5940](https://github.com/kubernetes-sigs/kustomize/pull/5940) - v5.8.0 に含まれたが回帰バグを引き起こした

## アップグレード判断（2026-02-10 更新）

### ✅ Kustomize v5.8.1 - 使用推奨

**ステータス**: 本番利用可能

- namespace 回帰バグ（#6014）は修正済み（PR #6044）
- Helm v3/v4 両対応（PR #6016）
- 本リポジトリで検証済み（11個の helmCharts アプリで動作確認）

### ⚠️ Helm v4 - 条件付き推奨

**前提条件**: Kustomize v5.8.1 以上

- Kustomize v5.8.1 が Helm v4 に対応
- Helm v4 にアップグレードする場合は、先に Kustomize v5.8.1 以上に更新すること

**現在の推奨構成**:
```yaml
# aqua.yaml
packages:
- name: kubernetes-sigs/kustomize@kustomize/v5.8.1  ✅
- name: helm/helm@v3.20.0  ✅ (v4 へのアップグレードも可能)
```

## クイックチェック用リンク

以下のリンクを順番に確認してください：

1. **Kustomize リリースページ**: https://github.com/kubernetes-sigs/kustomize/releases
   - v5.8.1 以降がリリースされているか確認
   - リリースノートで #6014 の修正が含まれているか確認

2. **Issue #6014**: https://github.com/kubernetes-sigs/kustomize/issues/6014
   - ステータス: Open / Closed
   - 最新コメントの内容

3. **Issue #6013**: https://github.com/kubernetes-sigs/kustomize/issues/6013
   - ステータス: Open / Closed

4. **PR #6016**: https://github.com/kubernetes-sigs/kustomize/pull/6016
   - ステータス: Open / Merged / Closed

## アップグレード手順

### Kustomize v5.8.1

✅ **本リポジトリは既に v5.8.1 を使用中**（Renovate による自動更新: commit `0ed32cb`）

新規セットアップまたは手動更新の場合:
```yaml
# aqua.yaml
packages:
- name: kubernetes-sigs/kustomize@kustomize/v5.8.1
- name: helm/helm@v3.20.0
```

### Helm v4 へのアップグレード（オプション）

Kustomize v5.8.1 使用時のみ可能:
```yaml
# aqua.yaml
packages:
- name: kubernetes-sigs/kustomize@kustomize/v5.8.1
- name: helm/helm@v4.1.0  # または最新の v4.x.x
```

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-02-10 | v5.8.1 検証完了。namespace 回帰バグ修正を確認。v5.8.1 + Helm v3.20.0 を推奨（Helm v4 も対応可能） |
| 2026-02-02 | 初版作成。v5.7.1 + Helm v3.20.0 を推奨 |

