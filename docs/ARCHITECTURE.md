# HomeLab Architecture

このドキュメントは、HomeLab環境の全体アーキテクチャを説明します。

## 概要

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Internet                                        │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                    ┌───────────────▼───────────────┐
                    │         Cloudflare            │
                    │  ┌─────────────────────────┐  │
                    │  │ DNS (harvestasya.org)   │  │
                    │  │ DNS (suzutan.jp)        │  │
                    │  │ Tunnel                  │  │
                    │  │ Zero Trust Access       │  │
                    │  └─────────────────────────┘  │
                    └───────────────┬───────────────┘
                                    │
                    ┌───────────────▼───────────────┐
                    │   Kubernetes Cluster          │
                    │        "k8s"              │
                    │                               │
                    │  ┌─────────────────────────┐  │
                    │  │   Ingress Layer         │  │
                    │  │  ┌───────┐ ┌─────────┐  │  │
                    │  │  │Traefik│ │CF Tunnel│  │  │
                    │  │  └───────┘ └─────────┘  │  │
                    │  └─────────────────────────┘  │
                    │                               │
                    │  ┌─────────────────────────┐  │
                    │  │   Core Services         │  │
                    │  │  ArgoCD, Keycloak       │  │
                    │  │  Pomerium, cert-manager │  │
                    │  │  CNPG, 1Password Op     │  │
                    │  └─────────────────────────┘  │
                    │                               │
                    │  ┌─────────────────────────┐  │
                    │  │   Applications          │  │
                    │  │  Immich, Navidrome      │  │
                    │  │  n8n, FreshRSS, etc.    │  │
                    │  └─────────────────────────┘  │
                    │                               │
                    │  ┌─────────────────────────┐  │
                    │  │   Monitoring (Temporis) │  │
                    │  │  Prometheus, Grafana    │  │
                    │  │  InfluxDB, Exporters    │  │
                    │  └─────────────────────────┘  │
                    │                               │
                    │  ┌─────────────────────────┐  │
                    │  │   Storage               │  │
                    │  │  NFS (nfs-client)       │  │
                    │  │  PostgreSQL (CNPG)      │  │
                    │  │  Redis/Valkey           │  │
                    │  └─────────────────────────┘  │
                    └───────────────────────────────┘
```

## コンポーネント詳細

### 1. Cloudflare Layer

| サービス | 用途 |
|---------|------|
| DNS | harvestasya.org, suzutan.jp のDNS管理 |
| Tunnel | 外部からクラスタへの安全なアクセス |
| Zero Trust Access | SSH含む認証・認可 |
| OIDC Integration | Keycloakとの連携 |

### 2. Ingress Layer

#### Traefik (Primary)
- **バージョン**: v37.4.0
- **レプリカ**: 2
- **機能**:
  - IngressRoute CRD
  - TLS終端
  - Middleware (security headers, compression等)

認証はPomerium IAPで処理されます。

#### Cloudflared Deployment
- **用途**: Cloudflare Tunnelへの接続

#### Ingress経路パターン

すべてのHTTPトラフィックはTraefikを経由します。

```
Internet → Cloudflare → Cloudflare Tunnel (cloudflared)
                                    │
                                    ▼
                               Traefik
                                    │
                                    ▼
                            IngressRoute
                                    │
     ┌────────────┬────────────┬────────────┬────────────┐
     ▼            ▼            ▼            ▼            ▼
   asf      navidrome      immich      grafana     その他
(Pomerium) (Pomerium)  (アプリ内認証) (アプリ内認証)
```

| 認証方式 | 対象アプリ |
|---------|-----------|
| Pomerium IAP | asf, navidrome, prometheus, traefik |
| アプリ内認証 | immich, grafana, influxdb, n8n |
| 認証なし | echoserver |
| 外部認証 | artonelico (Proxmox), argocd (Keycloak OIDC) |

### 3. Core Services

| サービス | 名前空間 | バージョン | 用途 |
|---------|---------|-----------|------|
| ArgoCD | argocd | v9.1.3 | GitOps管理 |
| Keycloak | keycloak | 26.x | Identity Provider (IdP) |
| Pomerium | pomerium | - | Identity-Aware Proxy (IAP) |
| cert-manager | cert-manager | v1.19.1 | TLS証明書管理 |
| CNPG Operator | cnpg-system | v0.26.1 | PostgreSQL管理 |
| 1Password Operator | onepassword | v2.0.5 | シークレット管理 |
| KubeVela | vela-system | v1.10.5 | アプリケーション抽象化 |

### 4. Application Layer

詳細は [APPLICATION_CATALOG.md](./APPLICATION_CATALOG.md) を参照。

### 5. Monitoring Stack (Temporis)

```
┌─────────────────────────────────────────────────────────────┐
│                    Temporis Namespace                        │
│                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │  Prometheus │───▶│   Thanos    │───▶│    InfluxDB2    │  │
│  │   v3.7.3    │    │   v0.40.1   │    │  (長期保存)      │  │
│  └──────┬──────┘    └─────────────┘    └─────────────────┘  │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────┐                                            │
│  │   Grafana   │  ダッシュボード:                            │
│  │   v12.3.0   │  - Node-Exporter                          │
│  └─────────────┘  - Remo-Exporter                          │
│         ▲         - Proxmox-Flux                            │
│         │                                                    │
│  ┌──────┴──────────────────────────────┐                    │
│  │            Exporters                 │                    │
│  │  ┌──────────────┐ ┌──────────────┐  │                    │
│  │  │Node-Exporter │ │Remo-Exporter │  │                    │
│  │  │  (DaemonSet) │ │(Nature Remo) │  │                    │
│  │  └──────────────┘ └──────────────┘  │                    │
│  │  ┌──────────────────────────────┐   │                    │
│  │  │    kube-state-metrics        │   │                    │
│  │  │       (kube-system)          │   │                    │
│  │  └──────────────────────────────┘   │                    │
│  └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

### 6. Storage Layer

#### NFS Storage (nfs-client StorageClass)
| PVC | サイズ | 用途 |
|-----|-------|------|
| immich-library | 100Gi | 写真・動画ストレージ |
| keycloak-postgresql | 動的 | Keycloak DB |
| grafana | 動的 | ダッシュボード永続化 |
| influxdb2 | 50Gi | メトリクス長期保存 |

#### Database Layer
```
┌─────────────────────────────────────────────────────────────┐
│                 CloudNative PostgreSQL                       │
│                                                              │
│  ┌─────────────────────┐    ┌─────────────────────┐         │
│  │  Immich Database    │    │   n8n Database      │         │
│  │  - 1 instance       │    │   - 1 instance      │         │
│  │  - 20Gi storage     │    │   - 1Gi storage     │         │
│  │  - VectorChord ext  │    │                     │         │
│  └─────────────────────┘    └─────────────────────┘         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Cache Layer                               │
│                                                              │
│  ┌─────────────────────┐                                    │
│  │  Valkey (Immich)    │                                    │
│  │  v5.0.8             │                                    │
│  └─────────────────────┘                                    │
└─────────────────────────────────────────────────────────────┘
```

## 認証・認可フロー

```
┌──────────┐     ┌──────────────┐     ┌─────────────────┐
│  User    │────▶│  Cloudflare  │────▶│    Pomerium     │
└──────────┘     │  Zero Trust  │     │     (IAP)       │
                 └───────┬──────┘     └────────┬────────┘
                         │                     │
                         ▼                     ▼
                 ┌──────────────┐     ┌─────────────────┐
                 │  Keycloak    │◀────│   OIDC Auth     │
                 │    (IdP)     │     │                 │
                 └──────────────┘     └─────────────────┘
                         │
                         ▼
                 ┌──────────────┐
                 │ 1Password    │
                 │   Vault      │
                 └──────────────┘
```

### 認証方式

| アプリケーション | 認証方式 |
|----------------|---------|
| ArgoCD | Keycloak OIDC |
| Traefik Dashboard | Pomerium IAP |
| Navidrome | Pomerium IAP |
| SSH Access | Cloudflare Zero Trust + Keycloak |
| Grafana | 1Password統合 |

## GitOps ワークフロー

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│  Developer  │────▶│   GitHub    │────▶│    Renovate     │
│             │     │  Repository │     │  (Auto Update)  │
└─────────────┘     └──────┬──────┘     └─────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   ArgoCD     │
                    │  (GitOps)    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Kubernetes  │
                    │   Cluster    │
                    └──────────────┘
```

1. **コード変更**: Developer がリポジトリにプッシュ
2. **自動更新**: Renovate が依存関係を自動更新・PR作成・マージ
3. **同期**: ArgoCD が変更を検知し自動デプロイ
4. **検証**: Prometheus/Grafana でメトリクス監視

## ネットワーク構成

詳細は [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) を参照。

## 関連ドキュメント

- [APPLICATION_CATALOG.md](./APPLICATION_CATALOG.md) - アプリケーション一覧
- [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) - ネットワーク構成
- [DATA_FLOW.md](./DATA_FLOW.md) - データフロー
- [SECRETS_MANAGEMENT.md](./SECRETS_MANAGEMENT.md) - シークレット管理
