# CLAUDE.md

This file defines guidelines and rules for Claude Code when working on this repository.

**Important: All conversations with the user should be conducted in Japanese (日本語).**

## Repository Overview

This repository manages Infrastructure as Code (IaC) for a personal HomeLab environment.

**For detailed documentation, see the `docs/` directory:**

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Overall architecture
- [NETWORK_TOPOLOGY.md](docs/NETWORK_TOPOLOGY.md) - Network configuration
- [APPLICATION_CATALOG.md](docs/APPLICATION_CATALOG.md) - Application catalog
- [DATA_FLOW.md](docs/DATA_FLOW.md) - Data flows
- [SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) - Secrets management
- [AGENT_MANAGEMENT.md](docs/AGENT_MANAGEMENT.md) - Agent team structure and workflow
- [TASK_WORKFLOW.md](docs/TASK_WORKFLOW.md) - Task management and session continuity

## Quick Reference

### Environment Information

| Item | Value |
|------|-------|
| Kubernetes Cluster Name | k8s |
| Primary Domains | harvestasya.org, suzutan.jp |
| GitOps | ArgoCD |
| Secrets Management | 1Password Operator |
| Ingress | Traefik + Cloudflare Tunnel |
| Identity Provider | Keycloak + Pomerium IAP |
| Monitoring | Prometheus + Grafana (temporis namespace) |

### Directory Structure

```
/infra
├── k8s/                      # Kubernetes manifests
│   ├── init/                     # Initialization scripts
│   │   └── onepassword-operator/ # 1Password initial setup
│   └── manifests/                # Application manifests
│       ├── argocd/               # ArgoCD configuration
│       ├── argocd-apps/          # ArgoCD Application definitions
│       ├── traefik/              # Ingress Controller
│       ├── cert-manager/         # TLS certificate management
│       ├── cnpg-operator/        # PostgreSQL Operator
│       ├── onepassword/          # Secrets management
│       ├── temporis/             # Monitoring stack
│       ├── immich/               # Photo management
│       ├── n8n/                  # Workflow automation
│       ├── navidrome/            # Music streaming
│       └── [other applications]
├── terraform/                    # Cloud infrastructure
│   ├── suzutan.jp/               # DNS/LAN configuration
│   ├── harvestasya.org/          # Cloudflare Tunnel/OIDC
│   └── modules/                  # Shared modules
│       └── fastmail/             # Email configuration
├── docs/                         # Documentation
├── aqua.yaml                     # Tool version management
├── renovate.json                 # Auto-update configuration
└── taskfile.yaml                 # Task definitions
```

## Key Components

### Kubernetes (k8s/)

- **ArgoCD**: GitOps management (v9.1.3)
- **Traefik**: Ingress Controller (v37.4.0, 2 replicas)
- **Keycloak**: Identity Provider
- **Pomerium**: Identity-Aware Proxy (IAP)
- **cert-manager**: TLS certificate management (v1.19.1)
- **CNPG Operator**: PostgreSQL management (v0.26.1)
- **1Password Operator**: Secrets management (v2.0.5)

### Terraform (terraform/)

- **Cloudflare DNS**: harvestasya.org, suzutan.jp
- **Cloudflare Tunnel**: External access tunnels
- **Zero Trust Access**: Access control including SSH

## Working Rules

### 1. File Formats and Style

**YAML Files:**
- Use 2-space indentation
- Format with `task yamlfmt`
- Follow standard Kubernetes manifest conventions

**Terraform:**
- Use HCL2 format
- Prefer modularization

### 2. Commit Messages

Use Conventional Commits format:
- `feat:` - New feature
- `fix:` - Bug fix
- `chore:` - Maintenance
- `docs:` - Documentation

### 3. Adding New Applications

1. Create `k8s/manifests/<app-name>/` directory
2. Required files:
   - `namespace.yaml` - Namespace definition
   - `kustomization.yaml` - Kustomize configuration
3. Add ArgoCD Application to `k8s/manifests/argocd-apps/`
4. Use `OnePasswordItem` for secrets

**Manifest Templates:**

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <app-name>
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: <app-name>
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
```

### 4. Secrets Management

**Required Rules:**
- Use 1Password Operator
- Direct secret commits are **prohibited**
- Use `secret-` prefix for secret names

**OnePasswordItem Definition:**

```yaml
apiVersion: onepassword.com/v1
kind: OnePasswordItem
metadata:
  name: <app>-secret
  namespace: <namespace>
spec:
  itemPath: "vaults/5mixaulvwor6zfvbfmtqlksdy4/items/<item-name>"
```

### 5. Ingress Configuration

**Traefik IngressRoute (internal):**

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: <app>
  namespace: <namespace>
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`<app>.harvestasya.org`)
      kind: Rule
      services:
        - name: <service>
          port: <port>
      middlewares:
        - name: security-headers
          namespace: traefik
  tls:
    secretName: harvestasya-wildcard-tls
```

**Note:** Authentication is handled by Pomerium IAP for protected routes.

**Cloudflare Tunnel Ingress (external exposure):**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <app>
  namespace: <namespace>
  annotations:
    kubernetes.io/ingress.class: cloudflare-tunnel
spec:
  rules:
    - host: <app>.harvestasya.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <service>
                port:
                  number: <port>
```

### 6. Database (PostgreSQL)

Use CloudNative PostgreSQL (CNPG):

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: <app>-database
  namespace: <namespace>
spec:
  instances: 1
  storage:
    size: 1Gi
    storageClass: nfs-client
```

### 7. Storage

**StorageClass:** `nfs-client`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <app>-data
  namespace: <namespace>
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
```

### 8. 開発サイクル（必須）

**すべての変更は以下のサイクルに従うこと。master への直接 push は禁止。**

```
1. git checkout master && git pull     # 最新の master をベースにする
2. git checkout -b <branch-name>       # feature/fix ブランチを作成
3. 変更を実装・コミット・プッシュ
4. gh pr create                        # PR を起票
5. CI 結果・レビューコメントを確認      # 要否判断のうえ対応
6. マージ要件を満たしたらマージ         # gh pr merge --squash
```

#### PR の CI チェック（GitHub Actions 自動実行）

| タイミング | チェック内容 |
|-----------|-------------|
| PR 作成時 | `terraform plan`（dry-run）、`terraform fmt check`、`k8s api deprecate check` |
| master マージ後 | `terraform apply`（自動適用） |

#### レビューとマージの判断基準

- CI が失敗している場合は原因を確認し対応する
- レビューコメント（gemini-code-assist 等）は内容を確認し、要否を判断して対応する
- ユーザーの確認が必要なクリティカルなレビュー以外は、マージ要件を満たしていれば自律的にマージしてよい

#### マージ後の反映

- **Terraform**: GitHub Actions が `terraform apply` を自動実行
- **k8s マニフェスト**: ArgoCD が自動で同期（2-3分以内）
- Renovate が依存関係を自動更新（必要に応じて）

### 9. ローカル検証

```bash
# YAML format check
task yamlfmt

# Kubernetes manifest validation
kubectl apply --dry-run=client -f <manifest.yaml>

# Terraform change verification
cd terraform/<directory>
terraform plan
```

## Prohibited Actions

- Do not commit production secrets directly
- Do not deviate from existing naming conventions
- Do not disable ArgoCD auto-sync (without special reason)
- Do not add unapproved services or tools
- Do not use Helm Charts directly; wrap with Kustomize

## Reference Implementations

When adding new applications, refer to these existing implementations:

| Pattern | Reference Directory |
|---------|---------------------|
| Helm + Kustomize | `k8s/manifests/traefik/` |
| Custom manifest + DB | `k8s/manifests/n8n/` |
| Authenticated Ingress | `k8s/manifests/navidrome/` |
| Monitoring stack | `k8s/manifests/temporis/` |
| CronJob | `k8s/manifests/ddns/` |

## Troubleshooting

### Manual Debugging with ArgoCD Running

**IMPORTANT**: ArgoCD automatically syncs from git, overwriting manual changes.
When debugging Kubernetes resources manually, **ALWAYS** scale down ArgoCD application-controller first:

```bash
# Scale down ArgoCD application-controller before manual debugging
kubectl scale statefulset -n argocd argocd-application-controller --replicas=0

# After debugging, scale back up
kubectl scale statefulset -n argocd argocd-application-controller --replicas=1
```

### ArgoCD Sync Errors

```bash
# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Check application status
kubectl get application -n argocd <app-name> -o yaml
```

### Secrets Not Created

```bash
# Check 1Password Operator logs
kubectl logs -n onepassword -l app=onepassword-connect

# Check OnePasswordItem status
kubectl get onepassworditem -n <namespace>
```

### Pod Not Starting

```bash
# Check Pod events
kubectl describe pod -n <namespace> <pod-name>

# Check logs
kubectl logs -n <namespace> <pod-name>
```

## Tool Versions (aqua.yaml)

| Tool | Version |
|------|---------|
| kustomize | v5.7.1 |
| kubectl | v1.23.0 |
| helm | v3.19.2 |
| terraform | v1.14.0 |

## Agent-Based Development Workflow

This repository uses specialized sub-agents for different tasks. See [AGENT_MANAGEMENT.md](docs/AGENT_MANAGEMENT.md) for full details.

### Available Agents (Slash Commands)

| Command | Agent | Purpose |
|---------|-------|---------|
| `/infra` | Infrastructure Agent | Kubernetes/Terraform changes |
| `/security` | Security Agent | Security auditing, secrets review |
| `/monitoring` | Monitoring Agent | Prometheus/Grafana configuration |
| `/review` | Review Agent | Pre-commit validation |
| `/docs` | Documentation Agent | Documentation updates |

### Standard Task Flow

```
User Request
    │
    ▼
┌─────────────────┐
│  Explore/Plan   │  Understand current state
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  /infra         │  Make infrastructure changes
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌──────────┐
│/security│ │/monitoring│  Parallel validation
└───┬───┘ └────┬─────┘
    └────┬─────┘
         ▼
┌─────────────────┐
│  /review        │  Final validation
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  /docs          │  Update documentation
└────────┬────────┘
         │
         ▼
     Commit
```

### Usage Examples

```bash
# Add new application
/infra Add new application "myapp" with PostgreSQL database

# Security audit before merge
/security Audit k8s/manifests/myapp/

# Validate changes
/review Check all files in k8s/manifests/myapp/

# Update docs after changes
/docs Update APPLICATION_CATALOG.md with myapp
```

### Task Management

**CRITICAL: All tasks must follow the persistent task management workflow.**

See [TASK_WORKFLOW.md](docs/TASK_WORKFLOW.md) for full details.

#### Session Start Protocol

```
1. Check .claude/tasks/CURRENT_TASK.md
2. If exists → Resume or confirm new task
3. If not exists → Create CURRENT_TASK.md for new tasks (REQUIRED)
```

#### During Task Execution

1. **TodoWrite** - In-memory task tracking (always use)
2. **CURRENT_TASK.md** - Persistent state file (update frequently)

Both must be kept in sync throughout the task.

#### Task State File Location

```
.claude/tasks/CURRENT_TASK.md
```

#### File Naming Convention

**IMPORTANT: Follow exact naming format**

| File | Format | Example |
|------|--------|---------|
| Active task | `CURRENT_TASK.md` | `.claude/tasks/CURRENT_TASK.md` |
| Archived task | `TASK-YYYYMMDD-HHMM.md` | `.claude/tasks/archive/TASK-20251201-1330.md` |

**DO NOT add descriptive suffixes to archive filenames.** Task description goes inside the file, not in the filename.

- Correct: `TASK-20251201-1330.md`
- Wrong: `TASK-20251201-1330-argocd-fix.md`

#### Mandatory Updates

Update CURRENT_TASK.md when:
- Starting a new phase
- Completing any step
- Making decisions
- Modifying files
- Encountering blockers
- Before any pause/interruption

#### Task Completion Protocol

1. Verify all steps completed
2. Archive: `mv CURRENT_TASK.md archive/TASK-YYYYMMDD-HHMM.md`
3. Clear TodoWrite
4. Commit archive file

#### Quick Reference

| Action | TodoWrite | CURRENT_TASK.md |
|--------|-----------|-----------------|
| Start task | Create todos | Create file |
| Start step | Mark in_progress | Log in Progress |
| Complete step | Mark completed | Update checklist |
| Modify file | - | Add to Modified Files |
| Decision made | - | Add to Decisions |
| Blocked | Keep in_progress | Add to Blockers |
| Session end | - | Update Next Steps |
| Task complete | Clear todos | Archive to `TASK-YYYYMMDD-HHMM.md` |

#### Parallel Agent Execution

When tasks are independent, launch agents in parallel:

```
# In single response, multiple Task calls:
Task(subagent_type="security", prompt="...")
Task(subagent_type="review", prompt="...")
```

Document parallel groups in CURRENT_TASK.md:
```markdown
### Phase 3: Validation (Parallel)
- [ ] Security audit [PARALLEL-GROUP-1]
- [ ] Review check [PARALLEL-GROUP-1]
```
