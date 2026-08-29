# AI-to-AI Handoff & Roadmap System

A file-based, git-tracked coordination system for multi-agent development workflows. Enables AI agents (and humans) to pick up work cold without re-deriving context from scratch, with explicit handoff protocols, verifiable state, and navigable dependency graphs.

## The Problem

AI agents coordinating on a codebase face three failure modes:

1. **Ephemeral** — State lives in conversations that end, not in something durable
2. **Unverifiable** — Even when written down, nothing checks state against reality, so it silently drifts
3. **Flat** — A plain document is a list, not a map. An agent can't tell what else is affected by what it's about to touch

This system fixes all three without requiring custom infrastructure.

## How It Works

### Two-Tier Roadmap Structure

```
/roadmap/
  MASTER.md              # Lightweight index — one entry per feature
  REGISTRY.md            # Canonical ID → current name/location map
  CHANGELOG.md           # Append-only, machine-parseable change log
  nodes/
    auth-module.md       # Detailed per-feature node
    driver-dashboard.md
    ...
```

**Tier 1 (MASTER.md):** Purpose, status, dependencies, last-verified commit hash  
**Tier 2 (nodes/*.md):** Interface contracts, acceptance criteria, decisions log, rejected approaches, open questions

### Two Roles

| Role | Responsibilities |
|------|-----------------|
| **Headmaster** | Sole writer of MASTER.md, REGISTRY.md, CHANGELOG.md. Verifies Officer work against acceptance criteria. Evaluates change-proposals. |
| **Officer** | Executes one scoped task. Reads node + dependencies before starting. Reserves node before work. Submits explicit claim with verification instructions. Cannot write to roadmap files. |

### Key Mechanisms

- **Commit-tied verification:** `Last verified` references a commit hash or test-run ID, not a timestamp. Staleness is computable.
- **Advisory reservations:** Officers reserve nodes with 48-hour TTL before starting work. Makes collisions visible before merge time.
- **Machine-parseable changelog:** Structured entries enable future automation (e.g., "show all changes affecting AUTH-01").
- **Canonical ID registry:** Prevents duplicate nodes for the same feature under different names.
- **Decision-log significance filter:** Only log decisions a different reasonable agent might have made differently.

## Getting Started

### Prerequisites

- Git repository
- AI coding agent (Claude Code, Cursor, Copilot, etc.) or human collaborators
- No custom backend or database required

### Installation

1. Create the roadmap directory structure:
```bash
mkdir -p /roadmap/nodes
touch /roadmap/MASTER.md /roadmap/REGISTRY.md /roadmap/CHANGELOG.md
```

2. Add the Headmaster and Officer skills to your agent's skills directory (e.g., `.claude/skills/` or `.github/skills/`)

3. Bootstrap your first feature node (see below)

### Bootstrap a Feature Node

When a feature has no node yet and is about to be handed to an Officer:

1. **Headmaster reads code first** — Review existing code for the feature
2. **Designer explains** — Describe what it's for, what's done vs. planned, invisible decisions
3. **Headmaster asks targeted questions** — Purpose, status, dependencies, decision-shaped choices
4. **Headmaster drafts** — Create MASTER.md entry and Tier 2 node file using schemas
5. **Designer reviews** — Confirm accuracy before commit (this is bootstrap verification)
6. **Commit** — Node is now governed by normal rules

**Minimum viable node:** Purpose, Status, Interface/Contract, Acceptance Criteria, Dependencies. Other fields can be empty at bootstrap.

### Run a Task

**As Headmaster:**
1. Assign Officer a scoped task with pointer to node and acceptance criteria
2. Officer executes task (see below)
3. Verify submission against acceptance criteria only
4. Merge on success; update node Status and MASTER.md

**As Officer:**
1. Read assigned node + dependencies
2. Check for reservation collisions
3. Add your reservation line with TTL
4. Execute task
5. Submit explicit claim: what done, how maps to criteria, how to verify
6. Do not mark done at top level — Headmaster verifies and updates

## Example

### MASTER.md Entry

```markdown
## [ID: AUTH-01] Authentication Module
Purpose: Handles driver + manager login, session tokens, role-based access.
Status: in progress
Detail: /roadmap/nodes/auth-module.md
Depends on: [DB-SCHEMA-01]
Depended on by: [DRIVER-DASH-01, MANAGER-REPORTS-01]
Last verified: commit a1b2c3d (2026-08-20)
```

### Tier 2 Node (nodes/auth-module.md)

```markdown
# [ID: AUTH-01] Authentication Module

## Interface / Contract
- `login(username, password) -> Token`
- `verifyToken(token) -> User | null`
- Called by: driver-dashboard.md, manager-reports.md
- Depends on: DB-SCHEMA-01 (users table)

## Status
- [x] Basic login flow — done, verified commit a1b2c3d
- [ ] Password reset flow — in progress, reserved by OFFICER-TASK-014, started 2026-08-27, expires 2026-08-29

## Acceptance Criteria
- `login()` returns valid token for correct credentials, null for incorrect, within 200ms
- `verifyToken()` rejects expired tokens
- Test suite `tests/auth_test.py` passes

## Decisions Log
- 2026-08-14: Chose JWT over session-cookie auth — FMS has both mobile and web clients; cookies don't work cleanly across both

## Rejected Approaches
- Local SQLite token storage (2026-08-12) — abandoned, caused sync issues across driver's multiple devices

## Open Questions / Blockers
- Unclear whether manager role needs separate token lifetime than driver role
```

### Changelog Entry

```markdown
[0042] 2026-08-27 | ROADMAP_CHANGE
node: AUTH-01
change: split password-reset into its own task, added rate-limiting requirement
reason: Officer flagged that reset flow needs abuse prevention before it can be marked done
affects: [AUTH-01, DRIVER-DASH-01]
```

## Design Rationale

See `references/design-rationale.md` for the full v4 specification, including:
- Why two roles (not three)
- Why manual-first / auto-extraction-later
- Why advisory reservations (not hard locks)
- Why commit-tied verification (not timestamps)
- Known limitations and deferred features

## When to Build Automation

This system starts manual. Build automation when:
- 3+ concurrent Officers are active, **or**
- 50+ active nodes exist, **or**
- Manual structural updates take >15 minutes per task

Triggers for:
- Auto-extraction of Interface/Contract from code
- Scripted stale-flag propagation
- CI/pre-commit validation

## License

MIT — use freely, adapt as needed. If you improve it, consider sharing back.

## Contributing

This is a pre-pilot spec. Before contributing:
1. Run the pilot on a real feature
2. Measure token savings vs. maintenance cost
3. Propose changes based on evidence, not speculation

See `references/design-rationale.md` §15 for pilot instructions.

---

**Status:** Pre-pilot. Operational spec v4. Ready for real-world validation.
