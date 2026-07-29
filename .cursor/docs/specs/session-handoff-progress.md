# Spec: Session handoff / progress contract (P0-A)

**Status:** Implemented  
**Size:** Medium  
**Tracking:** https://github.com/rhyanvargas/agentic-development-starter-kit/issues/59 · plan [`.cursor/plans/harness-p0-handoff-evaluator.plan.md`](../../plans/harness-p0-handoff-evaluator.plan.md)  
**Out of scope:** Ralph / GitHub-Issues AFK product; `.kiro` triad / Spec pane / wave runner; competing SDD pack

## Problem

Long-running agent work fails across session resets: agents one-shot too much, declare “done” early, or resume without reading living artifacts. ADSK already has **Clear** + living-spec sync, but no explicit multi-session **handoff/progress** contract.

## Success criteria

1. Medium+ sessions end with a durable progress note (what changed, what’s next `REQ`/`T#`, clean-git expectation).
2. Next session reads living spec + plan + progress **before** coding.
3. Skill + `/implement-spec` point at the contract; AFK non-goal remains explicit.
4. At least one output (or trigger) eval covers handoff behavior.

## Assumptions

1. Absorb into first-party `spec-driven-workflow` only (reference + thin skill/command pointers).
2. Prefer one-file living artifacts — progress lives as a **Handoff / Progress** section on the active plan (or living spec if no plan), not a new file triad.
3. Behavioral tests = skill evals + sync/skill CI; no runtime package changes required.

## Requirements

### REQ-HO-001 — Session-end checklist

`references/session-handoff.md` MUST define a Medium+ session-end checklist that includes:

- Progress note: completed work, open issues, files touched
- Next concrete work item (`REQ-XXX` and/or plan `T#`)
- Clean-git expectation (no half-applied WIP unless explicitly noted; prefer commit or stash guidance)

### REQ-HO-002 — Session-start checklist

Same reference MUST define a session-start checklist:

- Read living spec + plan + latest handoff/progress **before** coding
- Resync plan (`/plan-impl`) if living REQs changed since the plan
- Continue Clear habit: do not reload full prior exploration transcript

### REQ-HO-003 — Skill + Clear / implement wiring

`SKILL.md` Clear and Implement steps (and progressive-disclosure table) MUST point at `session-handoff.md`. Thin `/implement-spec` MUST mention start (read handoff) and end (write handoff when Medium+ work is incomplete or session is ending).

### REQ-HO-004 — Not an AFK product

Handoff docs MUST state this is a **HITL multi-session delivery harness** contract, not an AFK/Ralph loop. Link or cite `docs/product/agent-autonomy.md`.

### REQ-HO-005 — Eval coverage

Add an output eval (preferred) asserting handoff start/end behavior for Medium+ multi-session resume.

## Test strategy

| REQ | Check |
|-----|-------|
| HO-001..004 | Evidence review of reference + SKILL + command wording |
| HO-005 | `evals/evals.json` case |
| Shared | `./scripts/sync-adsk.sh kit` + `./scripts/check-skills-ci.sh` (+ soft evals self-test as needed) |

## Acceptance

Matches plan P0-A checklist in `.cursor/plans/harness-p0-handoff-evaluator.plan.md`.
