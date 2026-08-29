#!/bin/bash
# Setup script for AI Handoff Roadmap System
# Run this after cloning the repo to initialize the roadmap structure

echo "🚀 Setting up AI Handoff Roadmap System..."

# Create roadmap directories if they don't exist
mkdir -p roadmap/nodes

# Create empty roadmap files if they don't exist
if [ ! -f roadmap/MASTER.md ]; then
    echo "📝 Creating roadmap/MASTER.md..."
    cat > roadmap/MASTER.md << 'EOF'
# MASTER.md — Tier 1 Roadmap Index

This file is the lightweight entry point for the roadmap system. One entry per feature.

**Status vocabulary:** `not started` / `in progress` / `blocked` / `done` / `needs review`

---

## Example Entry

```markdown
## [ID: AUTH-01] Authentication Module
Purpose: Handles driver + manager login, session tokens, role-based access.
Status: in progress
Detail: /roadmap/nodes/auth-module.md
Depends on: [DB-SCHEMA-01]
Depended on by: [DRIVER-DASH-01, MANAGER-REPORTS-01]
Last verified: commit a1b2c3d (2026-08-20)
```

---

## Entries

<!-- Add entries here as features are bootstrapped -->
EOF
fi

if [ ! -f roadmap/REGISTRY.md ]; then
    echo "📝 Creating roadmap/REGISTRY.md..."
    cat > roadmap/REGISTRY.md << 'EOF'
# REGISTRY.md — Canonical ID Registry

| ID | Current name | Node file | Status |
|----|--------------|-----------|--------|
| <!-- Example: AUTH-01 --> | <!-- Example: Authentication Module --> | <!-- Example: nodes/auth-module.md --> | <!-- active / retired --> |

**Rule:** Before creating a new node, check this table. If the feature already has an ID, work happens on the existing node — never create a duplicate.

**When retiring an ID:** Mark it `retired` in the Status column rather than deleting the row — this prevents accidental reuse.
EOF
fi

if [ ! -f roadmap/CHANGELOG.md ]; then
    echo "📝 Creating roadmap/CHANGELOG.md..."
    cat > roadmap/CHANGELOG.md << 'EOF'
# CHANGELOG.md — Append-Only Change Log

Machine-parseable, structured entries. One entry per roadmap change.

## Format

```markdown
[0001] YYYY-MM-DD | ROADMAP_CHANGE
node: <NODE-ID>
change: <what changed>
reason: <why>
affects: [<NODE-ID>, ...]
```

---

## Entries

<!-- Add entries here as changes are made -->
EOF
fi

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy skills/headmaster.md and skills/officer.md to your agent's skills directory"
echo "2. Bootstrap your first feature node (see README.md §Bootstrap a Feature Node)"
echo "3. Run the pilot (see references/design-rationale.md §15)"
