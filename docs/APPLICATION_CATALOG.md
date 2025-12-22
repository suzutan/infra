# Application Catalog

このドキュメントは、HomeLab環境にデプロイされているすべてのアプリケーションを一覧化します。

## アプリケーション一覧

### Core Infrastructure

| アプリケーション | 名前空間 | バージョン | Helm Chart | 用途 |
|----------------|---------|-----------|------------|------|
| ArgoCD | argocd | v9.1.3 | argo/argo-cd | GitOps管理 |
| Traefik | traefik | v37.4.0 | traefik/traefik | Ingress Controller |
| cert-manager | cert-manager | v1.19.1 | jetstack/cert-manager | TLS証明書管理 |
| CNPG Operator | cnpg-system | v0.26.1 | cloudnative-pg/cloudnative-pg | PostgreSQL Operator |
| 1Password Operator | onepassword | v2.0.5 | 1password/connect | シークレット管理 |

### Authentication & Authorization

| アプリケーション | 名前空間 | バージョン | 用途 |
|----------------|---------|-----------|------|
| Authentik | authentik | 2025.10.2 | Identity Provider (IdP) |

**Authentik 詳細:**
- **Server**: 2レプリカ
- **Worker**: 2レプリカ
- **データベース**: CloudNative PostgreSQL
- **キャッシュ**: Redis (Bitnami)
- **OIDC連携**: ArgoCD, Cloudflare Zero Trust

### Applications

| アプリケーション | 名前空間 | イメージ/バージョン | 用途 | 外部URL |
|----------------|---------|-------------------|------|---------|
| Immich | immich | v2.3.1 | フォト管理 | chronicle.harvestasya.org |
| Navidrome | navidrome | カスタム | 音楽ストリーミング | navidrome.harvestasya.org |
| n8n | n8n | latest | ワークフロー自動化 | reyvateils.harvestasya.org |
| FreshRSS | freshrss | カスタム | RSSリーダー | - |
| ASF | asf | v6.3.0.1 | ArchiSteamFarm | asf.harvestasya.org |
| EchoServer | echoserver | カスタム | テストサーバー | echoserver.harvestasya.org |

### Monitoring (Temporis)

| コンポーネント | バージョン | 用途 |
|--------------|-----------|------|
| Prometheus | v3.7.3 | メトリクス収集 |
| Thanos | v0.40.1 | 長期保存・分散化 |
| Grafana | v12.3.0 | 可視化 |
| InfluxDB2 | Helm v2.1.2 | 時系列DB |
| Node-Exporter | DaemonSet | ノードメトリクス |
| Remo-Exporter | カスタム | Nature Remo監視 |
| kube-state-metrics | v2.17.0 | K8sメトリクス |

### Background Jobs

| アプリケーション | 名前空間 | タイプ | 用途 |
|----------------|---------|-------|------|
| DDNS | ddns | CronJob | 動的DNS更新 |
| HSR Auto Claimer | hsr-auto-claimer | CronJob | 自動実行タスク |

---

## アプリケーション詳細

### Immich

写真・動画管理サービス。

```
┌─────────────────────────────────────────────────────────┐
│                    Immich Namespace                      │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   Server    │  │     ML      │  │   PostgreSQL    │  │
│  │  (v2.3.1)   │  │  (v2.3.1)   │  │   (CNPG)        │  │
│  └──────┬──────┘  └──────┬──────┘  │   - 1 instance  │  │
│         │                │         │   - 20Gi        │  │
│         │                │         │   - VectorChord │  │
│         └────────┬───────┘         └─────────────────┘  │
│                  │                                       │
│         ┌────────▼────────┐       ┌─────────────────┐   │
│         │     Valkey      │       │  NFS Storage    │   │
│         │     (v5.0.8)    │       │  - 100Gi        │   │
│         └─────────────────┘       └─────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

**リソース制限:**
- Server: CPU 100m-4, Memory 512Mi-4Gi
- ML: GPU対応可能

**マニフェスト:** `freesia/manifests/immich/`

### Authentik

認証・認可プラットフォーム (Identity Provider)。

```
┌─────────────────────────────────────────────────────────┐
│                  Authentik Namespace                     │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐                       │
│  │   Server    │  │   Worker    │                       │
│  │  (2 pods)   │  │  (2 pods)   │                       │
│  └──────┬──────┘  └──────┬──────┘                       │
│         │                │                               │
│         └────────┬───────┘                               │
│                  │                                       │
│    ┌─────────────▼─────────────┐                        │
│    │       PostgreSQL          │                        │
│    │    (Bitnami Chart)        │                        │
│    └───────────────────────────┘                        │
│                                                          │
│    ┌───────────────────────────┐                        │
│    │         Redis             │                        │
│    │    (Bitnami Chart)        │                        │
│    └───────────────────────────┘                        │
└─────────────────────────────────────────────────────────┘
```

**OIDC設定:**
- Client: ArgoCD, Cloudflare Access
- Scopes: openid, profile, email
- グループクレーム: 有効

**マニフェスト:** `freesia/manifests/authentik/`

### n8n

ワークフロー自動化プラットフォーム。

**構成:**
- レプリカ: 1
- データベース: PostgreSQL (CNPG)
- ストレージ: 1Gi

**リソース制限:**
- CPU: 100m - 1
- Memory: 250Mi - 500Mi

**マニフェスト:** `freesia/manifests/n8n/`

### Navidrome

音楽ストリーミングサーバー。

**構成:**
- レプリカ: 1
- 認証: Authentik Forward Auth
- 追加: FileBrowser サイドカー

**マニフェスト:** `freesia/manifests/navidrome/`

### ArgoCD

GitOps継続的デリバリーツール。

**構成:**
- Helm Chart: argo/argo-cd v9.1.3
- 認証: Authentik OIDC
- Kustomize: Helm統合有効

**Projects:**
1. **k8s-infra**: 基盤コンポーネント
2. **apps**: アプリケーション

**マニフェスト:** `freesia/manifests/argocd/`

### Traefik

Ingress Controller。

**構成:**
- Helm Chart: traefik/traefik v37.4.0
- レプリカ: 2
- CRD: IngressRoute

**Middleware:**
- security-headers
- authentik-forward-auth
- compress
- circuit-breaker

**マニフェスト:** `freesia/manifests/traefik/`

---

## 名前空間一覧

| 名前空間 | 用途 | アプリケーション |
|---------|------|----------------|
| argocd | GitOps | ArgoCD |
| authentik | 認証 | Authentik |
| asf | ゲーム | ArchiSteamFarm |
| cert-manager | 証明書 | cert-manager |
| cnpg-system | DB Operator | CNPG Operator |
| ddns | DNS | DDNS CronJob |
| echoserver | テスト | EchoServer |
| freshrss | RSS | FreshRSS |
| hsr-auto-claimer | 自動化 | HSR Auto Claimer |
| immich | フォト | Immich |
| kube-system | システム | kube-state-metrics, NFS Provisioner |
| n8n | 自動化 | n8n |
| navidrome | 音楽 | Navidrome |
| onepassword | シークレット | 1Password Operator |
| temporis | 監視 | Prometheus, Grafana, InfluxDB |
| traefik | Ingress | Traefik |

---

## デプロイパターン

### Helm + Kustomize

```
freesia/manifests/<app>/
├── kustomization.yaml     # Kustomize設定
├── namespace.yaml         # 名前空間定義
├── helmrelease.yaml       # Helm値 (values.yaml相当)
└── patches/               # パッチファイル (オプション)
```

### カスタムマニフェスト

```
freesia/manifests/<app>/
├── kustomization.yaml
├── namespace.yaml
├── deployment.yaml
├── service.yaml
├── ingress.yaml           # または ingressroute.yaml
└── onepassworditem.yaml   # シークレット参照
```

---

## Container Registry

| レジストリ | 用途 |
|-----------|------|
| ghcr.io | GitHub Container Registry |
| quay.io | Red Hat |
| registry.k8s.io | Kubernetes公式 |
| public.ecr.aws | AWS ECR Public |
| docker.io | Docker Hub |

---

## バージョン管理

すべてのアプリケーションバージョンは **Renovate** によって自動管理されています。

- **自動マージ**: 有効
- **セマンティックコミット**: feat, fix, chore
- **更新対象**: Helm Chart, Container Image, Kustomization
