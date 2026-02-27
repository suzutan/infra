# adg - AdGuard Home Client Management CLI

AdGuard Home の `dns-query/<識別子>` によるクライアント管理を CLI で行うためのツール。

クライアントの追加・削除時に `allowed_clients`（許可リスト）も自動で同期するため、Web UI での手動操作が不要になる。

## セットアップ

### ビルド

```bash
# taskfile 経由
task adg:build

# 直接ビルド
cd tools/adg && go build -o adg .
```

### 接続設定

環境変数で AdGuard Home への接続情報を設定する。

```bash
export ADGUARD_HOST="adguard.ssa.suzutan.jp"
export ADGUARD_USERNAME="admin"
export ADGUARD_PASSWORD="xxxxx"
export ADGUARD_SCHEME="https"   # デフォルト: https
```

## コマンド

### client - クライアント管理

```bash
# 一覧表示
adg client list

# 追加（allowed_clients にも自動追加）
adg client add "iPhone" --id iphone-suzutan --tag device_phone --tag os_ios

# 削除（allowed_clients からも自動削除）
adg client remove "iPhone"
```

`client add` / `client remove` は AdGuard Home のクライアント定義と `allowed_clients` を一括で操作する。

### access - 許可リスト管理

```bash
# 許可クライアント一覧
adg access list

# 手動で許可リストに追加
adg access add <client-id>

# 手動で許可リストから削除
adg access remove <client-id>
```

クライアント定義を変更せず `allowed_clients` だけを操作したい場合に使う。

### sync - YAML からの宣言的同期

```bash
# YAML 定義を同期（追加・更新のみ）
adg sync clients.yaml

# YAML に無いクライアントも削除
adg sync clients.yaml --prune
```

#### YAML フォーマット

```yaml
clients:
  - name: iPhone
    ids:
      - iphone-suzutan
    tags:
      - device_phone
      - os_ios
  - name: MacBook
    ids:
      - macbook-suzutan
    tags:
      - device_laptop
      - os_macos
```

サンプルファイル: [`clients.yaml.example`](clients.yaml.example)

#### sync の動作

1. AdGuard Home から現在のクライアント一覧と `allowed_clients` を取得
2. YAML 定義との差分を計算
3. 追加・更新を実行（削除は `--prune` 指定時のみ）
4. `allowed_clients` を YAML 内の全 `ids` で同期（YAML 管理外のエントリは保持）

## ディレクトリ構成

```
tools/adg/
├── main.go                # エントリポイント
├── go.mod
├── go.sum
├── cmd/
│   ├── root.go            # ルートコマンド + API クライアント初期化
│   ├── client.go          # client list/add/remove
│   ├── access.go          # access list/add/remove
│   └── sync.go            # sync コマンド
├── clients.yaml.example   # YAML 定義サンプル
└── README.md
```

## 依存ライブラリ

| ライブラリ | 用途 |
|-----------|------|
| [gmichels/adguard-client-go](https://github.com/gmichels/adguard-client-go) | AdGuard Home API クライアント |
| [spf13/cobra](https://github.com/spf13/cobra) | CLI フレームワーク |
| [gopkg.in/yaml.v3](https://pkg.go.dev/gopkg.in/yaml.v3) | YAML パース（sync コマンド用） |
