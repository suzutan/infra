# Agent Management Policy

This document defines the team structure and management policy for Claude Code sub-agents working on this HomeLab infrastructure repository.

## Team Structure Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Claude Code (Orchestrator)                         │
│                                                                              │
│  Responsibilities:                                                           │
│  - Task decomposition and delegation                                         │
│  - Progress tracking via TodoWrite                                           │
│  - Final review and user communication                                       │
│  - Escalation handling                                                       │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│  Infrastructure│       │   Security    │       │  Monitoring   │
│     Agent     │       │    Agent      │       │    Agent      │
└───────────────┘       └───────────────┘       └───────────────┘
        │                         │                         │
        ▼                         ▼                         ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│    Review     │       │    Explore    │       │ Documentation │
│    Agent      │       │    Agent      │       │    Agent      │
└───────────────┘       └───────────────┘       └───────────────┘
```

## Agent Definitions

### 1. Infrastructure Agent (`/infra`)

**Role:** Kubernetes and Terraform infrastructure changes

**Responsibilities:**
- Create/modify Kubernetes manifests
- Create/modify Terraform configurations
- Implement new applications following established patterns
- Database and storage provisioning
- Ingress and networking configuration

**Trigger Conditions:**
- Adding new applications
- Modifying existing deployments
- Terraform changes (DNS, Tunnel, etc.)
- Storage/database modifications

**Required Context:**
- `docs/ARCHITECTURE.md`
- `docs/APPLICATION_CATALOG.md`
- Reference implementations in `freesia/manifests/`

### 2. Security Agent (`/security`)

**Role:** Security auditing and secrets management

**Responsibilities:**
- Audit manifests for security issues
- Verify 1Password integration
- Check RBAC configurations
- Review Ingress/TLS settings
- Validate no secrets in commits

**Trigger Conditions:**
- Before merging new applications
- Periodic security reviews
- When modifying authentication flows
- Secrets-related changes

**Required Context:**
- `docs/SECRETS_MANAGEMENT.md`
- `docs/NETWORK_TOPOLOGY.md`
- 1Password Operator configurations

### 3. Monitoring Agent (`/monitoring`)

**Role:** Observability and alerting configuration

**Responsibilities:**
- Configure Prometheus scrape targets
- Create/modify Grafana dashboards
- Set up alerting rules
- Verify metrics exposure
- InfluxDB configuration

**Trigger Conditions:**
- Adding new applications requiring monitoring
- Alert configuration changes
- Dashboard updates
- Metrics debugging

**Required Context:**
- `docs/DATA_FLOW.md` (Monitoring section)
- `freesia/manifests/temporis/`
- Existing ServiceMonitor configurations

### 4. Review Agent (`/review`)

**Role:** Code review and validation

**Responsibilities:**
- Validate Kubernetes manifests
- Check Kustomize build
- Verify naming conventions
- Ensure documentation updates
- Pre-commit validation

**Trigger Conditions:**
- Before committing changes
- Pull request reviews
- After significant modifications

**Validation Checklist:**
- [ ] YAML formatting (`task yamlfmt`)
- [ ] Kustomize build success
- [ ] No hardcoded secrets
- [ ] Proper namespace usage
- [ ] Label/annotation consistency
- [ ] Documentation updated

### 5. Explore Agent (`/explore`)

**Role:** Codebase investigation and analysis

**Responsibilities:**
- Find existing patterns and implementations
- Analyze dependencies between components
- Locate configuration files
- Understand current state

**Trigger Conditions:**
- Understanding existing implementations
- Finding similar patterns
- Investigating issues
- Before making changes

**Output Format:**
- File locations with line numbers
- Dependency relationships
- Pattern recommendations

### 6. Documentation Agent (`/docs`)

**Role:** Documentation maintenance

**Responsibilities:**
- Update architecture documentation
- Maintain application catalog
- Update network topology
- Keep CLAUDE.md current
- Generate change summaries

**Trigger Conditions:**
- After infrastructure changes
- New application additions
- Configuration changes
- Periodic reviews

**Documentation Standards:**
- ASCII diagrams for architecture
- Tables for catalogs
- YAML examples for configurations
- Keep docs/ in sync with actual state

## Task Workflow

### Standard Development Flow

```
┌──────────────┐
│  User Task   │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│   Explore    │────▶│   Planning   │
│    Agent     │     │  (TodoWrite) │
└──────────────┘     └──────┬───────┘
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
       ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│Infrastructure│    │   Security   │    │  Monitoring  │
│    Agent     │    │    Agent     │    │    Agent     │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                    │                    │
       └────────────────────┼────────────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │   Review     │
                    │    Agent     │
                    └──────┬───────┘
                            │
                            ▼
                    ┌──────────────┐
                    │Documentation │
                    │    Agent     │
                    └──────┬───────┘
                            │
                            ▼
                    ┌──────────────┐
                    │    Commit    │
                    └──────────────┘
```

### Task Assignment Rules

| Task Type | Primary Agent | Supporting Agents |
|-----------|---------------|-------------------|
| New Application | Infrastructure | Security, Monitoring, Docs |
| Bug Fix | Explore → Infrastructure | Review |
| Security Audit | Security | Explore |
| Monitoring Setup | Monitoring | Infrastructure |
| Documentation | Documentation | Explore |
| Code Review | Review | Security |
| Investigation | Explore | - |

### Parallel Execution

When possible, agents should be invoked in parallel:

```
# Good: Independent tasks in parallel
- Security audit + Monitoring check (parallel)
- Then: Review (sequential, depends on above)

# Bad: Sequential when not needed
- Security audit
- Wait...
- Monitoring check
- Wait...
```

## Quality Gates

### Pre-Commit Checklist

1. **Infrastructure Agent** completed changes
2. **Security Agent** approved (no vulnerabilities)
3. **Review Agent** validated:
   - `task yamlfmt` passes
   - `kubectl apply --dry-run=client` succeeds
   - No secrets in code
4. **Documentation Agent** updated relevant docs

### Escalation Rules

| Condition | Action |
|-----------|--------|
| Security vulnerability found | Stop, notify user immediately |
| Breaking change detected | Request user confirmation |
| Unclear requirements | Ask user via AskUserQuestion |
| Conflict with existing pattern | Present options to user |

## Agent Communication

### Context Sharing

Agents share context through:
1. **TodoWrite** - Task progress and status
2. **File system** - Created/modified files
3. **Orchestrator** - Summary passed between agents

### Handoff Protocol

When delegating to another agent:

```markdown
## Task Handoff

**From:** Infrastructure Agent
**To:** Security Agent

**Completed:**
- Created deployment.yaml
- Created service.yaml
- Created ingressroute.yaml

**Files to Review:**
- freesia/manifests/newapp/deployment.yaml
- freesia/manifests/newapp/ingressroute.yaml

**Concerns:**
- Verify TLS configuration
- Check RBAC requirements
```

## Metrics and Tracking

### Task Completion Metrics

Track via TodoWrite:
- Tasks created
- Tasks completed
- Tasks blocked
- Average completion time (implicit)

### Quality Metrics

- Security issues found per review
- Documentation coverage
- Validation failures caught

## Configuration

### Enabling Agents

Agents are available as slash commands in `.claude/commands/`:

```
.claude/commands/
├── infra.md        # Infrastructure Agent
├── security.md     # Security Agent
├── monitoring.md   # Monitoring Agent
├── review.md       # Review Agent
├── explore.md      # Explore Agent (built-in enhanced)
└── docs.md         # Documentation Agent
```

### Usage Examples

```bash
# Invoke specific agent
/infra Add new application called "example"

# Security review
/security Audit the immich deployment

# Before commit
/review Check all changes in freesia/manifests/newapp/

# Update documentation
/docs Update APPLICATION_CATALOG.md with new app
```

## Best Practices

### DO:
- Use Explore Agent before making changes
- Run Security Agent on all new code
- Update documentation with every change
- Use parallel execution when possible
- Track all tasks with TodoWrite

### DON'T:
- Skip security reviews
- Commit without Review Agent validation
- Leave documentation outdated
- Make changes without understanding context
- Ignore escalation rules

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2024-11 | 1.0 | Initial agent management policy |
