# Kustomize + Helm 互換性チェックリスト

このドキュメントは、Kustomize と Helm のバージョンアップグレード可否を判断するためのチェックリストです。

## 現在の使用バージョン

| ツール | バージョン | 設定ファイル |
|--------|-----------|-------------|
| Kustomize | v5.7.1 | `aqua.yaml` |
| Helm | v3.20.0 | `aqua.yaml` |

## 追跡中の問題

### 1. helmCharts の namespace 回帰バグ

**Issue**: [#6014 - v5.8.0 breaks namespace behaviour in HelmChartInflationGenerator](https://github.com/kubernetes-sigs/kustomize/issues/6014)

**概要**: Kustomize v5.8.0 で、HelmChartInflationGenerator 使用時に namespace がレンダリングされたマニフェストから消失する。v5.7.1 では正常に動作。

**チェック方法**:
1. Issue #6014 がクローズされているか確認
2. クローズされている場合、修正が含まれるリリースバージョンを確認

### 2. Helm v4 との互換性問題

**Issue**: [#6013 - Fix an error with Helm v4](https://github.com/kubernetes-sigs/kustomize/issues/6013)

**PR**: [#6016](https://github.com/kubernetes-sigs/kustomize/pull/6016)

**概要**: Helm v4.0.0 で `-c` フラグが削除されたため、`kustomize build --enable-helm` が失敗する。

**チェック方法**:
1. PR #6016 がマージされているか確認
2. マージされている場合、修正が含まれるリリースバージョンを確認

### 3. 元々の namespace 伝播問題（参考）

**Issue**: [#5566 - Kustomize doesn't pass namespace to helmCharts](https://github.com/kubernetes-sigs/kustomize/issues/5566)

**修正PR**: [#5940](https://github.com/kubernetes-sigs/kustomize/pull/5940) - v5.8.0 に含まれたが回帰バグを引き起こした

## アップグレード判断フローチャート

```
Kustomize をアップグレードしたい
          │
          ▼
┌─────────────────────────────┐
│ Issue #6014 はクローズ済み？ │
└─────────────┬───────────────┘
              │
      No ─────┴───── Yes
       │              │
       ▼              ▼
   アップグレード   ┌─────────────────────────────┐
   しない          │ 修正バージョンがリリース済み？│
                   └─────────────┬───────────────┘
                                 │
                         No ─────┴───── Yes
                          │              │
                          ▼              ▼
                      アップグレード   そのバージョンに
                      しない          アップグレード可能
```

```
Helm v4 にアップグレードしたい
          │
          ▼
┌─────────────────────────────┐
│ PR #6016 はマージ済み？      │
└─────────────┬───────────────┘
              │
      No ─────┴───── Yes
       │              │
       ▼              ▼
   アップグレード   ┌─────────────────────────────┐
   しない          │ 修正版 Kustomize リリース済み？│
                   └─────────────┬───────────────┘
                                 │
                         No ─────┴───── Yes
                          │              │
                          ▼              ▼
                      アップグレード   Kustomize を先に
                      しない          アップグレードしてから
                                      Helm v4 にアップグレード
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

すべての問題が解決されたことを確認したら：

```yaml
# aqua.yaml を更新
packages:
- name: kubernetes-sigs/kustomize@kustomize/v5.X.X  # 修正版に更新
- name: helm/helm@v3.20.0  # または v4.X.X（互換性確認後）
```

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-02-02 | 初版作成。v5.7.1 + Helm v3.20.0 を推奨 |

