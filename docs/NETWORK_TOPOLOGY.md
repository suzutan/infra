# Network Topology

このドキュメントは、HomeLab環境のネットワーク構成を説明します。

## 全体構成

```
                              ┌─────────────────────────────────────┐
                              │            Internet                  │
                              └──────────────────┬──────────────────┘
                                                 │
                              ┌──────────────────▼──────────────────┐
                              │           Cloudflare                 │
                              │  ┌───────────────────────────────┐  │
                              │  │  DNS Zones                    │  │
                              │  │  - harvestasya.org            │  │
                              │  │  - suzutan.jp                 │  │
                              │  └───────────────────────────────┘  │
                              │  ┌───────────────────────────────┐  │
                              │  │  Cloudflare Tunnel            │  │
                              │  │  - harvestasya ssh            │  │
                              │  └───────────────────────────────┘  │
                              │  ┌───────────────────────────────┐  │
                              │  │  Zero Trust Access            │  │
                              │  │  - OIDC (Authentik)           │  │
                              │  └───────────────────────────────┘  │
                              └──────────────────┬──────────────────┘
                                                 │
                    ┌────────────────────────────┴────────────────────────────┐
                    │
         ┌──────────▼──────────┐
         │  Cloudflare Tunnel  │
         │    (cloudflared)    │
         │  Deployment (2pods) │
         └──────────┬──────────┘
                    │
                    ▼
         ┌─────────────────────────────────────────────┐
         │          Kubernetes Cluster                  │
         │               "k8s"                      │
         │         Node: node01 (172.20.2.2)           │
         │                                              │
         │  ┌────────────────────────────────────────┐ │
         │  │         Traefik (Ingress)              │ │
         │  │  - 2 replicas                          │ │
         │  │  - ClusterIP Service                   │ │
         │  │  - IngressRoute CRD                    │ │
         │  └────────────────────────────────────────┘ │
         │                     │                       │
         │                     ▼                       │
         │  ┌────────────────────────────────────────┐ │
         │  │         Application Services           │ │
         │  │  (各名前空間)                           │ │
         │  └────────────────────────────────────────┘ │
         └─────────────────────────────────────────────┘
```

## DNS構成

### harvestasya.org (Zone ID: 98fc606abe946efeabebe1fdbf0af490)

| ホスト名 | タイプ | 値 | Proxy |
|---------|-------|-----|-------|
| chronicle | CNAME | Tunnel | Yes |
| grathnode | CNAME | R2 Custom Domain | Yes |
| reyvateils | CNAME | Tunnel | Yes |
| navidrome | A | Internal | No |
| navidrome-filebrowser | CNAME | Tunnel | Yes |
| asf | CNAME | Tunnel | Yes |
| traefik | A | Internal | No |
| prometheus | CNAME | Tunnel | Yes |
| grafana | CNAME | Tunnel | Yes |
| echoserver | CNAME | Tunnel | Yes |
| ssh | CNAME | Tunnel | Yes |
| argocd | CNAME | Tunnel | Yes |

### suzutan.jp (Zone ID: 6617900ee27c2ec450dcd1e5da53f156)

| ホスト名 | タイプ | 値 | 用途 |
|---------|-------|-----|------|
| spica | CNAME | - | Cloudflare Proxy |
| atria | CNAME | - | Cloudflare Proxy |

## Ingress構成

### Traefik IngressRoute

```yaml
# 典型的なIngressRoute設定
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: example
  namespace: example
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`example.harvestasya.org`)
      kind: Rule
      services:
        - name: example-service
          port: 80
      middlewares:
        - name: security-headers
        - name: authentik-forward-auth  # 認証が必要な場合
  tls:
    secretName: harvestasya-wildcard-tls
```

### Cloudflare Tunnel経路

すべてのHTTPトラフィックは以下の経路で処理されます：

```
Cloudflare Edge → Cloudflare Tunnel (cloudflared deployment)
                              ↓
                          Traefik
                              ↓
                       IngressRoute
                              ↓
                         Service
```

Cloudflare Tunnelの設定はcloudflaredデプロイメントで管理され、
すべてのトラフィックはTraefikを経由してルーティングされます。

## 公開エンドポイント一覧

すべてのHTTPトラフィックはCloudflare Tunnel → Traefik → IngressRouteの経路を通ります。

| ホスト名 | アプリケーション | 認証 |
|---------|----------------|------|
| argocd.harvestasya.org | ArgoCD | Authentik OIDC |
| artonelico.harvestasya.org | Proxmox (外部) | Proxmox認証 |
| asf.harvestasya.org | ArchiSteamFarm | Authentik Forward Auth |
| chronicle.harvestasya.org | Immich | アプリ内認証 |
| echoserver.harvestasya.org | EchoServer | なし |
| grafana.harvestasya.org | Grafana | アプリ内認証 |
| grathnode.harvestasya.org | Cloudflare R2 | R2バケット (ストレージ) |
| influxdb2.harvestasya.org | InfluxDB | アプリ内認証 |
| navidrome.harvestasya.org | Navidrome | Authentik Forward Auth |
| navidrome-filebrowser.harvestasya.org | FileBrowser | Authentik Forward Auth |
| prometheus.harvestasya.org | Prometheus | Authentik Forward Auth |
| reyvateils.harvestasya.org | n8n | アプリ内認証 |
| traefik.harvestasya.org | Traefik Dashboard | Authentik Forward Auth |
| ssh.harvestasya.org | SSH Access | Zero Trust (SSH専用) |

## Traefik Middleware

### security-headers
```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: security-headers
spec:
  headers:
    stsSeconds: 31536000
    stsIncludeSubdomains: true
    stsPreload: true
    forceSTSHeader: true
    contentTypeNosniff: true
    browserXssFilter: true
    referrerPolicy: "strict-origin-when-cross-origin"
    customFrameOptionsValue: "SAMEORIGIN"
```

### authentik-forward-auth
```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: authentik-forward-auth
spec:
  forwardAuth:
    address: http://authentik-server.authentik.svc.cluster.local/outpost.goauthentik.io/auth/traefik
    trustForwardHeader: true
    authResponseHeaders:
      - X-authentik-username
      - X-authentik-groups
      - X-authentik-email
      - X-authentik-name
      - X-authentik-uid
```

### その他のMiddleware
| 名前 | 用途 |
|------|------|
| auto-detect-content-type | MIME型自動検出 |
| ban-robots | ロボット排除 |
| circuit-breaker | 障害時サーキットブレーカー |
| compress | レスポンス圧縮 |

## TLS証明書

### ワイルドカード証明書
| ドメイン | 発行元 | Secret名 |
|---------|--------|----------|
| *.harvestasya.org | Let's Encrypt | harvestasya-wildcard-tls |
| *.suzutan.jp | Let's Encrypt | suzutan-wildcard-tls |

### 証明書発行設定
```yaml
# ClusterIssuer (Let's Encrypt)
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cert-manager-cloudflare
              key: api-token
```

## 内部ネットワーク

### Kubernetes ネットワーク構成

| 項目 | 値 | 備考 |
|------|-----|------|
| Pod CIDR | 10.244.0.0/16 | Flannel/Cilium 共通 |
| Service CIDR | 10.96.0.0/12 | Kubernetes デフォルト |
| CNI | Cilium 1.18.5 | kube-proxy 無効化、Hubble 有効 |

### CNI (Cilium) 設定

```yaml
# 主要設定
kubeProxyReplacement: true      # kube-proxy をCiliumで置き換え
k8sServiceHost: localhost       # KubePrism エンドポイント
k8sServicePort: 7445

# Hubble (オブザーバビリティ)
hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true
```

詳細: `k8s/manifests/cilium/values.yaml`

### 主要サービスエンドポイント
| サービス | 名前空間 | DNS |
|---------|---------|-----|
| Traefik | traefik | traefik.traefik.svc.cluster.local |
| Authentik Server | authentik | authentik-server.authentik.svc.cluster.local |
| Prometheus | temporis | prometheus.temporis.svc.cluster.local |
| Grafana | temporis | grafana.temporis.svc.cluster.local |

## Cloudflare Tunnel

### トンネル構成
```
Cloudflare Edge ─────▶ Cloudflare Tunnel ─────▶ CF Tunnel Ingress Controller
                                                         │
                                                         ▼
                                               Kubernetes Services
```

### SSH Tunnel設定
- **ホスト**: ssh.harvestasya.org
- **ポート**: 22
- **認証**: Cloudflare Zero Trust (Authentik OIDC必須)
- **トークン**: Terraform random生成 (64文字)

## セキュリティ考慮事項

### 外部アクセス
1. すべての外部トラフィックはCloudflare経由
2. Zero Trust Accessによる認証
3. HTTPS強制 (HSTS有効)

### 内部通信
1. Pod間通信は平文許可 (クラスタ内)
2. 機密データはService Mesh検討予定

### ファイアウォール
- Cloudflare IPのみ信頼
- 直接アクセスは拒否
