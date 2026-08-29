# AI-to-AI / Multi-Agent Handoff & Roadmap System — Implementation Plan v4

**Status:** pre-build. This is the operational spec used to run the pilot in §15.

**Changes from v3:** added §0 Bootstrap — how a roadmap actually gets created for a feature that doesn't have one yet, via a code-read → conversation → clarifying questions → draft → designer review → commit flow, done incrementally per feature/module rather than as one upfront pass over the whole project.

---

## 0. Bootstrap — Creating a Roadmap Node for the First Time

Nothing before this section addressed how a node comes into existence. The "Headmaster is the sole writer" rule governs ongoing maintenance — it does not mean the Headmaster has to silently infer an entire feature's purpose and history from code alone. For a feature that has no node yet, bootstrap it like this:

**Step 1 — Headmaster reads first**  
Before involving the designer, the Headmaster does an initial pass over whatever code already exists for the feature/module in question (if any). This isn't meant to produce a finished node — it's so the Headmaster shows up to the conversation with informed, specific questions instead of asking the designer to narrate everything from zero.

**Step 2 — Designer explains**  
The designer (you) describes the feature: what it's for, what's done vs. still planned, anything not obvious from the code — including things that will never be visible from code alone, like why a particular approach was rejected, or why something is deliberately left basic for now.

**Step 3 — Headmaster asks clarifying questions**  
Questions should target exactly what the node schema needs and nothing more:
- Purpose/scope — if not already clear from the conversation.
- Status — which pieces are genuinely done vs. in progress vs. not started, using the fixed vocabulary (§6).
- Dependencies it couldn't verify from code alone (e.g., planned integrations, things that don't exist yet).
- Anything decision-shaped — a non-obvious choice, or a rejected approach — since these never get inferred, only told (§8's Decisions Log / Rejected Approaches rule applies here too).

The Headmaster should not ask about anything it could have answered itself from the code — that defeats the point of doing Step 1 first.

**Step 4 — Headmaster drafts**  
Using the conversation, the Headmaster drafts the Tier 1 MASTER.md entry and the Tier 2 node file, following the exact schemas in §6 and §8.

**Step 5 — Designer reviews before commit**  
This is the one point in the whole system where there's no Acceptance Criteria to verify against yet — the draft itself has none, since it's what's establishing them. So the designer's review is the verification step for bootstrap, in place of the normal Headmaster-verifies-against-criteria flow. The Headmaster should not treat its own draft as canonical until the designer has confirmed it.

**Step 6 — Commit**  
Once confirmed, the Headmaster commits the node into MASTER.md and creates the node file. From this point forward, the node is governed by the normal ongoing rules (§4 onward) — no special bootstrap treatment continues past this step.

### Scope of bootstrap: incremental, not upfront

Bootstrap happens per feature/module, as needed — not as one large session trying to roadmap the entire project before any Officer work can begin. Since FMS is under active development rather than frozen, requiring a complete roadmap before the system becomes useful would delay every benefit this system is meant to provide. A feature gets bootstrapped when it's about to be handed to an Officer for the first time, not before.

### What this does not change

- The Headmaster is still the sole writer of MASTER.md, REGISTRY.md, and CHANGELOG.md — bootstrap doesn't create an exception to that, it's still the Headmaster performing the write, just informed by a conversation instead of solitary code-reading.
- Officers are still not involved in bootstrap. A node should exist (even in draft form, mid-review) before any task is assigned against it.

---

## 1. System Overview

Two roles — Headmaster and Officer — coordinate through a shared, file-based roadmap that lives in the project repo and is versioned by git. The roadmap has two tiers: a lightweight Master index and detailed per-feature nodes. All state changes are recorded as an append-only changelog, not silent edits. No custom app or backend is required to run this.

**Core principle, unchanged since v1:** an agent should never have to re-derive what it can instead read from a small, targeted, verifiable file.

---

## 2. Goals / Non-Goals

### Goals

- Let any AI (or human) pick up a task cold and understand current state without re-reading the whole project or a full conversation history.
- Make relationships between files/features explicit and navigable (blast radius visible before editing).
- Keep the source of truth close to verifiable reality, not just prose someone wrote once.
- Work across multiple AI tools, not just one vendor's agent framework.
- Stay cheap to adopt — no custom app/backend required to start.

### Non-goals (for now)

- A GUI/dashboard for browsing the graph.
- True real-time fine-grained locking between agents (git's commit-level model plus advisory reservations, §9, is treated as sufficient for now).
- Cross-project/cross-repo shared memory.
- Any scripted/automated propagation or enforcement beyond the single hook described in §12. See §16 for what was deliberately left out and why.
- A single upfront roadmap-everything session — bootstrap is incremental by design (§0).

---

## 3. File Layout

```
/roadmap/
  MASTER.md              # Tier 1 — index, one entry per feature
  REGISTRY.md            # canonical stable-ID → current name/location map
  CHANGELOG.md           # append-only, machine-parseable entries
  nodes/
    auth-module.md        # Tier 2 — detail file
    driver-dashboard.md
    manager-reports.md
    ...
```

All plain text, all git-tracked. No database, no service.

---

## 4. Roles — Exact Responsibilities

### Headmaster

- Sole writer of MASTER.md, REGISTRY.md, and CHANGELOG.md.
- Runs the bootstrap conversation (§0) for any feature that doesn't yet have a node.
- Sole authority to merge Officer work into canonical project files.
- Verifies submitted work against that task's acceptance criteria only — never re-reviews the whole project. (Exception: bootstrap itself, §0 Step 5, where the designer's review substitutes for acceptance-criteria verification since none exist yet.)
- Evaluates and decides on change-proposals (§9).
- Responsible for keeping last-verified markers honest (§8) — never advances one without a real check.
- Sole writer of a node's top-level Status: field, its Decisions Log, and its Rejected Approaches section.

### Officer

- Executes exactly one scoped task, assigned by the Headmaster with a pointer to the relevant node(s). A node must exist (post-bootstrap, §0) before an Officer can be assigned against it.
- Reads the node + its declared neighbors before starting (§11, rule 1).
- Reserves the node before starting work (§9).
- Never writes to MASTER.md, REGISTRY.md, or CHANGELOG.md.
- Can check off its own task line in a node's Status checklist and add notes to that node's Open Questions section.
- Cannot change a node's top-level Status field in MASTER.md, and cannot add or edit Decisions Log or Rejected Approaches entries — those route through the Headmaster.
- Submits work as an explicit claim: what was done, how it maps to the task, how to verify it.
- May submit a change-proposal instead of/alongside a task submission (§9), but cannot self-approve it.

### Auditor (deferred, not active at MVP)

Not used until there's evidence of correctness gaps the Headmaster's alignment check misses. Documented so adding it later doesn't require redesigning the two roles above.

---

## 5. Officer Write Boundary — Explicit

**Officer can:**
- Check off its own assigned line in a node's Status checklist (e.g. `- [x] Basic login flow — done`).
- Add or edit entries in that node's Open Questions / Blockers section.
- Add its own reservation line (§9).

**Officer cannot:**
- Change the node's or the feature's top-level Status: field (as it appears in MASTER.md).
- Add or edit Decisions Log entries.
- Add or edit Rejected Approaches entries.
- Write to MASTER.md, REGISTRY.md, or CHANGELOG.md under any circumstance.
- Create a new node from scratch — new nodes only come from the Headmaster via bootstrap (§0).

Everything in the "cannot" list routes through the Headmaster. This exists specifically so an Officer can't mark a node done before the Headmaster has actually checked it against acceptance criteria.

---

## 6. Master File (MASTER.md) — Exact Schema

One entry per feature:

```markdown
## [ID: AUTH-01] Authentication Module
Purpose: Handles driver + manager login, session tokens, role-based access.
Status: in progress
Detail: /roadmap/nodes/auth-module.md
Depends on: [DB-SCHEMA-01]
Depended on by: [DRIVER-DASH-01, MANAGER-REPORTS-01]
Last verified: commit a1b2c3d (2026-08-20)
```

**Rules:**
- Status is restricted to exactly one of: `not started` / `in progress` / `blocked` / `done` / `needs review`. No free text.
- Last verified is tied to a commit hash or test-run ID, never a bare timestamp.
- ID is the canonical identifier (§10) and never changes even if the title/description does.

---

## 7. Node Reservation (with TTL)

Before starting work, an Officer adds a reservation line to the node's Status section:

```markdown
- [ ] Password reset flow — in progress, reserved by OFFICER-TASK-014, started 2026-08-27, expires 2026-08-29
```

**Default TTL:** 48 hours from start. The Headmaster can extend it — extension is a Headmaster action, not something an Officer grants itself.

**Advisory, not a hard lock.** Its purpose is to make an in-progress collision visible before submission rather than discovered only at merge time; the TTL prevents a crashed or abandoned session from blocking a node indefinitely.

---

## 8. Tier 2 Node — Exact Schema

Fields, in the order they should appear (most tasks should be able to stop reading early):

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
- `login()` returns a valid token for correct credentials, null for incorrect, within 200ms.
- `verifyToken()` rejects expired tokens.
- Existing test suite `tests/auth_test.py` passes.

## Decisions Log
(Headmaster-only. Only log decisions that would change if a different reasonable agent made the call.)
- 2026-08-14: Chose JWT over session-cookie auth because FMS has both mobile driver clients and web manager clients; cookies don't work cleanly across both.

**Examples of what NOT to log:**
- ✅ Log: "Chose JWT over session-cookie auth because FMS has both mobile and web clients."
- ❌ Don't log: "Named the function `login` instead of `authenticate`."

## Rejected Approaches
(Headmaster-only.)
- Tried storing tokens in local SQLite on-device (2026-08-12) — abandoned, caused sync issues across driver's multiple devices.

## Open Questions / Blockers
(Officer can add/edit.)
- Unclear whether manager role needs a separate token lifetime than driver role. Needs Headmaster decision before Role-based permission check task starts.
```

**Node size — principle, not a hard number:** if a node is getting long enough that an Officer skims instead of reading, split it into sub-nodes. Watch this during the pilot rather than pre-committing to a number now.

---

## 9. Change-Proposal Flow

Used when an Officer's work surfaces a reason the plan itself should change — not a normal task submission.

1. Officer submits: what it wants changed, why, and which node IDs it affects downstream.
2. Headmaster evaluates — judgment, not test-based verification.
3. If approved, Headmaster:
   - updates MASTER.md and/or the relevant node(s),
   - writes a CHANGELOG.md entry (§13),
   - manually adds a stale-flag to every affected node (kept manual — see §16).

**Stale-flag propagation:** any node listed as `affects` gets a visible marker (e.g. ⚠ plan changed since 2026-08-27, see CHANGELOG#0042) at the top of its Status section. Any Officer already mid-task on that node sees this the next time it reads the node (§11, rule 1) and must re-check with the Headmaster before continuing.

---

## 10. Canonical ID Registry (REGISTRY.md) — with deprecation field

| ID              | Current name             | Node file                     | Status   |
|-----------------|--------------------------|-------------------------------|----------|
| AUTH-01         | Authentication Module    | nodes/auth-module.md          | active   |
| DRIVER-DASH-01  | Driver Dashboard         | nodes/driver-dashboard.md     | active   |
| AUTH-OLD        | (deprecated)             | —                             | retired  |

**Rule:** before creating a new node, check this table. If the feature already has an ID, work happens on the existing node — never create a second node for something that already exists under a different name. New entries only get added here as part of bootstrap (§0) or a Headmaster-approved change-proposal (§9) — never by an Officer.

---

## 11. Working Rules (apply to every agent)

1. **Read-before-write** — read the node + its declared neighbors before touching anything.
2. **Verify-before-trust** — check status claims against the recorded commit/test-run, not just the prose status.
3. **Write-on-completion** — update the relevant node's Status checklist / Open Questions before considering work done (within the Officer write boundary, §5).
4. **Decision-logging** — Headmaster applies the significance filter (§8); Officers don't write decisions directly.
5. **Conflict-declaration** — a reservation collision or disagreeing update gets flagged to the Headmaster, never silently overwritten.
6. **Canonical naming** — resolve to the Registry ID; never invent a new label for an existing node.

---

## 12. Permission Enforcement

Claude Code cannot currently scope permissions so a main session (Headmaster) is blocked from a path while its own subagents (Officers) are allowed, or vice versa — subagents inherit the parent session's permission rules. This is an open platform limitation, not a configuration gap.

**Decision for MVP:** single session + hook tripwire. A PreToolUse hook blocks direct writes to `/roadmap/MASTER.md`, `/roadmap/REGISTRY.md`, and `/roadmap/CHANGELOG.md` for every agent; the only sanctioned update path is the Headmaster explicitly performing the edit itself. Deterministic, but not adversary-proof — accepted, not hidden.

**Revisit trigger:** if concurrent Officers or external contributors are added, re-evaluate fully separate Headmaster/Officer sessions.

---

## 13. Changelog Format (CHANGELOG.md) — machine-parseable

```markdown
[0042] 2026-08-27 | ROADMAP_CHANGE
node: AUTH-01
change: split password-reset into its own task, added rate-limiting requirement
reason: Officer flagged that reset flow needs abuse prevention before it can be marked done
affects: [AUTH-01, DRIVER-DASH-01]
```

Structured, one entry per change, append-only.

---

## 14. Auto-Extraction of the Structural Layer — Sequencing, with concrete triggers

Not built yet. Sequencing: manual first, on a constrained surface (only populate Interface/Contract for nodes actively being touched), auto-extraction later.

**Build auto-extraction when any one of these is true:**
- (a) 3 or more concurrent Officers are active, or
- (b) the roadmap has 50 or more active nodes, or
- (c) manual structural updates are measurably taking more than ~15 minutes per task.

---

## 15. Pilot Plan (with bootstrap + control task)

1. Pick one real FMS feature.
2. Bootstrap it using the §0 flow — code-read, conversation, clarifying questions, draft, your review, commit. This is now an explicit pilot step, not assumed to have already happened.
3. **Control run:** do the same real task twice, cold, without the node, in separate sessions. Record token usage and time-to-productive-start for both runs.
4. **Test run:** do the same task a third time, cold, using only the bootstrapped node — no other context.
5. **Compare** the test run against the control range (not a single control run) to see whether the difference exceeds ordinary variance.
6. Also measure:
   - Time to bootstrap the node (from code-read to commit).
   - Headmaster time spent on clarifying questions, drafting, and review.
   - Officer time spent reading the node vs. reading code (if measurable).

Only after this produces real numbers: decide whether to build the stale-flag propagation script, bootstrap a second feature, or adjust the auto-extraction triggers in §14.

Nothing past step 6 gets built until step 5 produces evidence the approach saves more than ordinary session variance would explain.

---

## 16. Deliberately Deferred (and why)

- **Scripted stale-flag propagation.** Right idea, wrong timing — building automation before knowing how often change-proposals actually happen contradicts the "let manual usage reveal the schema before automating" principle (§14). Stays manual (§9) until the pilot shows it's a real bottleneck.
- **Pre-commit hook checking MASTER.md/CHANGELOG.md consistency.** Same reasoning as deferring CI enforcement in §12 — real value eventually, not needed to validate the core idea.
- **Periodic node-pruning rules and a separate Headmaster merge-checklist for collision-checking.** Premature — zero nodes exist before the pilot runs, and the merge-checklist mostly restates what the reservation field (§7) already does structurally.
- **A single upfront "roadmap the whole project" bootstrap session.** Rejected in favor of incremental, per-feature bootstrap (§0) — FMS is under active development, and gating all Officer work behind a complete roadmap would delay every benefit this system is meant to provide.

---

## 17. Summary of What Changed from v3

| v4 Addition | Problem it closes |
|-------------|-------------------|
| §0 Bootstrap flow (code-read → conversation → questions → draft → review → commit) | No prior version explained how a node comes into existence in the first place |
| Bootstrap is incremental, per-feature | Prevents the system from requiring a complete roadmap before any Officer work can start |
| Designer review as the verification step during bootstrap | Bootstrap has no acceptance criteria to verify against yet — this names what substitutes for it |
| Officer write-boundary explicitly includes "cannot create a new node" | Closes a gap where node creation wasn't clearly excluded from Officer permissions before |

---

**This is the operational spec for the pilot in §15. Nothing beyond the pilot gets built until it produces real evidence.**
