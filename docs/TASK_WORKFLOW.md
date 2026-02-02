# Task Workflow Management

This document defines the task management workflow for Claude Code sessions. All tasks must follow this workflow to ensure continuity across sessions.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Task Lifecycle                                       │
│                                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │  Start   │───▶│  Plan    │───▶│ Execute  │───▶│ Complete │              │
│  │          │    │          │    │          │    │          │              │
│  └──────────┘    └──────────┘    └─────┬────┘    └──────────┘              │
│                                        │                                     │
│                                        │ Interrupt                           │
│                                        ▼                                     │
│                                  ┌──────────┐                                │
│                                  │ Suspend  │                                │
│                                  │          │                                │
│                                  └─────┬────┘                                │
│                                        │                                     │
│                                        │ Resume                              │
│                                        ▼                                     │
│                                  ┌──────────┐                                │
│                                  │ Continue │                                │
│                                  │          │                                │
│                                  └──────────┘                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Task State File

### Location

```
.claude/tasks/CURRENT_TASK.md
```

### Purpose

- Tracks the current task state
- Enables session resumption
- Documents progress and decisions

### Template

```markdown
# Current Task

## Metadata
- **Task ID:** TASK-YYYYMMDD-HHMM
- **Started:** YYYY-MM-DD HH:MM
- **Last Updated:** YYYY-MM-DD HH:MM
- **Status:** in_progress | suspended | blocked

## Request
[Original user request verbatim]

## Objective
[Clear statement of what needs to be accomplished]

## Context
[Relevant background information discovered during exploration]

## Plan
### Phase 1: [Phase Name]
- [ ] Step 1.1
- [ ] Step 1.2

### Phase 2: [Phase Name]
- [ ] Step 2.1
- [ ] Step 2.2

## Progress Log
### YYYY-MM-DD HH:MM
- [Action taken]
- [Result/outcome]

### YYYY-MM-DD HH:MM
- [Action taken]
- [Result/outcome]

## Modified Files
| File | Action | Status |
|------|--------|--------|
| path/to/file.yaml | Created | Done |
| path/to/other.tf | Modified | In Progress |

## Decisions Made
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| Use X approach | Because Y | Z was considered but... |

## Blockers / Open Questions
- [ ] Blocker 1 - [description]
- [ ] Question 1 - [waiting for user input]

## Next Steps
1. [Immediate next action]
2. [Following action]

## Notes
[Any additional context for future sessions]
```

## Workflow Phases

### Phase 1: Task Initialization

When a new task is received:

1. **Check for existing task**
   ```
   Read .claude/tasks/CURRENT_TASK.md if exists
   ```

2. **If existing task found:**
   - Display task summary to user
   - Ask: "Continue existing task or start new?"

3. **If starting new task:**
   - Create `CURRENT_TASK.md` with template
   - Fill in Metadata, Request, Objective sections

4. **Use TodoWrite** to create in-memory task list

### Phase 2: Planning

1. **Explore codebase** (if needed)
   - Use Explore Agent or direct tools
   - Document findings in Context section

2. **Create detailed plan**
   - Break down into phases
   - Identify dependencies
   - Note potential blockers

3. **Update CURRENT_TASK.md** with plan

4. **Sync TodoWrite** with plan steps

### Phase 3: Execution

For each step:

1. **Mark step as in_progress** (both file and TodoWrite)

2. **Execute the step**
   - Use appropriate agents if needed
   - Can parallelize independent work

3. **Log progress** in CURRENT_TASK.md
   - Timestamp
   - Actions taken
   - Results

4. **Update Modified Files** table

5. **Mark step completed**

6. **Commit checkpoint** (if significant milestone)
   - Update CURRENT_TASK.md
   - Ensure file is saved

### Phase 4: Completion

1. **Verify all steps completed**

2. **Run final validations**
   - `/review` agent
   - Any tests

3. **Update documentation** if needed
   - `/docs` agent

4. **Archive task file**
   ```
   Move to .claude/tasks/archive/TASK-YYYYMMDD-HHMM.md
   ```

5. **Clear TodoWrite**

## Suspension & Resumption

### Automatic Suspension Triggers

- Session timeout
- User requests pause
- Blocking issue encountered

### Suspension Protocol

1. **Update CURRENT_TASK.md**
   - Set Status to `suspended`
   - Update Last Updated timestamp
   - Fill in Next Steps section
   - Document any in-flight work

2. **Ensure all files are saved**

3. **Log suspension reason** in Progress Log

### Resumption Protocol

When starting a new session:

1. **Check for CURRENT_TASK.md**
   ```
   If .claude/tasks/CURRENT_TASK.md exists:
     Read and parse task state
     Display summary to user
     Confirm resumption
   ```

2. **Restore context**
   - Read Modified Files list
   - Review Progress Log
   - Understand Next Steps

3. **Update status**
   - Set Status to `in_progress`
   - Update timestamp

4. **Continue from Next Steps**

## Parallel Execution

### When to Parallelize

- Independent validation tasks (Security + Review)
- Multiple file creations with no dependencies
- Research across different areas

### How to Parallelize

1. **Identify independent tasks** in plan

2. **Mark parallel group** in CURRENT_TASK.md
   ```markdown
   ### Phase 2: Validation (Parallel)
   - [ ] Security audit [PARALLEL-GROUP-1]
   - [ ] Review validation [PARALLEL-GROUP-1]
   - [ ] Monitoring check [PARALLEL-GROUP-1]
   ```

3. **Launch agents together** using multiple Task tool calls

4. **Wait for all to complete** before proceeding

### Parallel Agent Example

```
# In a single response, launch multiple agents:
Task(subagent_type="security", prompt="Audit X")
Task(subagent_type="review", prompt="Validate Y")
```

## Integration with Agents

### Agent Selection by Task Type

| Task Type | Primary Agent | When to Use |
|-----------|---------------|-------------|
| New app | /infra | Creating Kubernetes manifests |
| Security check | /security | Before commit, audits |
| Monitoring | /monitoring | Dashboard, alerts setup |
| Pre-commit | /review | Final validation |
| Research | Explore (built-in) | Understanding codebase |
| Documentation | /docs | Updating docs/ files |

### Agent Handoff

When switching between agents:

1. **Update CURRENT_TASK.md** with completed work
2. **Log handoff** in Progress Log
3. **Pass context** via prompt to next agent

## File Structure

```
.claude/
├── commands/           # Slash command definitions
│   ├── infra.md
│   ├── security.md
│   ├── monitoring.md
│   ├── review.md
│   └── docs.md
├── tasks/              # Task state management
│   ├── CURRENT_TASK.md # Active task (if any)
│   └── archive/        # Completed tasks
│       └── TASK-*.md
└── settings.json       # Claude Code settings
```

## Best Practices

### DO:

1. **Always update CURRENT_TASK.md** after significant actions
2. **Use timestamps** in Progress Log
3. **Document decisions** with rationale
4. **List all modified files** as you go
5. **Checkpoint frequently** - save state often
6. **Use TodoWrite in parallel** with file updates

### DON'T:

1. **Don't skip the task file** for "quick" tasks
2. **Don't leave Next Steps empty** when suspending
3. **Don't forget to archive** completed tasks
4. **Don't parallelize dependent tasks**
5. **Don't ignore blockers** - document them

## Example: Full Task Lifecycle

```markdown
# Current Task

## Metadata
- **Task ID:** TASK-20241201-1430
- **Started:** 2024-12-01 14:30
- **Last Updated:** 2024-12-01 15:45
- **Status:** in_progress

## Request
Add new application "webhook-relay" with PostgreSQL database

## Objective
Deploy webhook-relay application with:
- Kubernetes deployment
- PostgreSQL database (CNPG)
- IngressRoute with Pomerium IAP
- 1Password secrets integration

## Context
- Similar to n8n deployment pattern
- Uses existing CNPG operator
- Uses Pomerium for authentication

## Plan
### Phase 1: Setup
- [x] Create namespace
- [x] Create kustomization.yaml

### Phase 2: Core Components
- [x] Create deployment.yaml
- [ ] Create service.yaml
- [ ] Create CNPG database cluster

### Phase 3: Networking
- [ ] Create IngressRoute
- [ ] Configure TLS

### Phase 4: Validation (Parallel)
- [ ] Security audit [PARALLEL]
- [ ] Review validation [PARALLEL]

## Progress Log
### 2024-12-01 14:35
- Created namespace.yaml and kustomization.yaml
- Based structure on n8n reference

### 2024-12-01 14:50
- Created deployment.yaml
- Set resource limits based on existing patterns

### 2024-12-01 15:45 [SUSPENDED]
- Session interrupted by user
- Deployment created, service next

## Modified Files
| File | Action | Status |
|------|--------|--------|
| k8s/manifests/webhook-relay/namespace.yaml | Created | Done |
| k8s/manifests/webhook-relay/kustomization.yaml | Created | Done |
| k8s/manifests/webhook-relay/deployment.yaml | Created | Done |
| k8s/manifests/webhook-relay/service.yaml | Planned | Pending |

## Decisions Made
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| Use 256Mi memory limit | Lightweight Go service | 512Mi (overkill) |
| Single replica | Non-critical service | 2 replicas (unnecessary) |

## Blockers / Open Questions
- None

## Next Steps
1. Create service.yaml
2. Create CNPG database cluster
3. Create IngressRoute with Pomerium

## Notes
- Remember to add to argocd-apps after completion
- User prefers minimal resource allocation
```

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2024-12 | 1.0 | Initial task workflow definition |
