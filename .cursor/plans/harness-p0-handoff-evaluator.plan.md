---
name: Harness P0 — handoff + evaluator
overview: "Track two P0 kit features that future-proof ADSK as a delivery harness (not more agent power): multi-session handoff/progress contract, and generator≠evaluator split for /review. Dogfood is deferred but remains the preferred validation gate before merge."
todos:
  - id: T0
    content: DEFER — Dogfood Runs 1–2 (medium feature + bugfix) when capacity allows; log skips/ratchets
    status: cancelled
  - id: T1
    content: P0-A — Spec + absorb session handoff/progress contract into SDD (Clear / living-spec); no AFK product
    status: completed
  - id: T2
    content: P0-A — Implement handoff refs + thin command/skill updates; evals; sync-adsk kit
    status: completed
  - id: T3
    content: P0-B — Spec evaluator-split protocol for /review (refute-minded, separate from implement)
    status: completed
  - id: T4
    content: P0-B — Implement /review hardening + evals; sync-adsk kit
    status: completed
  - id: T5
    content: Ship — PR(s) with Conventional Commits; refresh create-adsk snapshot if commands change
    status: completed
isProject: false
---

# Plan: Harness P0 — handoff + evaluator

**Status:** Implemented (T1–T5 sync/snapshot done); open PR when operator asks; dogfood deferred (T0).  
**Thesis:** Process + feedback loops beat more agent power — these P0s make ADSK the **multi-session delivery harness**.

## Handoff / Progress

- **Updated:** 2026-07-29
- **Done:** T1–T5 + review fixes (REQ-HO-001 files touched; REQ-HO-004 HITL wording)
- **Files:** skills/spec-driven-workflow/**, .cursor/commands/{implement-spec,review}.md, .cursor/docs/specs/{session-handoff-progress,review-evaluator-split}.md, packages/create-adsk/kit-snapshot/**
- **Now:** commit + push `feat/harness-p0-handoff-evaluator` (issues #59 / #60); optional dogfood T0
- **Watchouts:** Dogfood T0 still deferred
- **Git:** dirty on branch feat/harness-p0-handoff-evaluator (committing)

## Tracked work (the two P0s)

| ID | Feature | Outcome |
|----|---------|---------|
| **P0-A** | Session handoff / progress contract | Medium+ sessions end in clean handoff (progress note + next REQ); next session reads living spec + plan + progress before coding |
| **P0-B** | Evaluator split for `/review` | Generator ≠ evaluator; refute-minded review pass (spec, regression fence, security-sensitive paths) |

## Deferred (not blocking tracking)

| ID | Item | Note |
|----|------|------|
| **T0** | Dogfood Runs 1–2 | Preferred validation before merging P0-A/B; skip for now; run when able |

## Locked defaults (non-goals)

- No Ralph / GitHub-Issues AFK product ([`docs/product/agent-autonomy.md`](../../docs/product/agent-autonomy.md))
- No `.kiro` triad / Spec pane / wave runner
- No competing SDD pack; absorb into first-party `spec-driven-workflow`
- Prefer one-file living artifacts; progressive disclosure in `references/`

## Evidence (why these two)

- [Anthropic — Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — progress files, incremental sessions, premature “done”
- [Anthropic — Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) — separate evaluator vs self-grading
- [Osmani — Agent Harness Engineering](https://addyosmani.com/blog/agent-harness-engineering/) — generator/evaluator split; harness encodes model limits
- Kit thesis: [`docs/product/for-eng-leads.md`](../../docs/product/for-eng-leads.md)

## Requirements → tasks

| Requirement | Tasks |
|-------------|-------|
| Dogfood when able | T0 |
| P0-A specify | T1 |
| P0-A implement + evals | T2 |
| P0-B specify | T3 |
| P0-B implement + evals | T4 |
| Ship / snapshot | T5 |

## Suggested sequencing

```
T0 (optional, anytime) 
     ↓ preferred before merge
T1 → T2  (P0-A)
T3 → T4  (P0-B; can parallelize with A after T1/T3 specs exist)
     ↓
T5 ship
```

P0-A and P0-B may ship as **one PR** or **two** if review load is high — keep Conventional Commit scopes clear (`feat(spec-driven-workflow): …`).

## Acceptance (when work resumes)

### P0-A
- [x] Reference docs session start/end checklist (progress + next REQ + clean git expectation)
- [x] SDD `SKILL.md` / Clear / implement path points at it
- [x] Explicit “not an AFK product” boundary preserved
- [x] Trigger or output eval covering handoff behavior

### P0-B
- [x] `/review` (and skill review phase) requires separate evaluate posture
- [x] Bugfix path: review checks Unchanged fence
- [x] Eval covering “do not self-grade as done without review pass”

### Shared
- [x] `./scripts/sync-adsk.sh kit` after skill/command edits
- [x] If Cursor commands change → `./scripts/prepare-create-adsk-snapshot.sh` (+ npm bump only if adopters need it)

## GitHub tracking

| P0 | Issue |
|----|-------|
| **P0-A** handoff / progress | https://github.com/rhyanvargas/agentic-development-starter-kit/issues/59 |
| **P0-B** evaluator `/review` | https://github.com/rhyanvargas/agentic-development-starter-kit/issues/60 |

Plan path (Cursor todos): `.cursor/plans/harness-p0-handoff-evaluator.plan.md`

## Out of scope (later roadmap)

- Ratchet playbook (P1)
- Delivery ground-truth scorecard (P1)
- Orchestration playbook docs-only (P2)
