# Spec: Evaluator split for `/review` (P0-B)

**Status:** Implemented  
**Size:** Medium  
**Tracking:** https://github.com/rhyanvargas/agentic-development-starter-kit/issues/60 · plan [`.cursor/plans/harness-p0-handoff-evaluator.plan.md`](../../plans/harness-p0-handoff-evaluator.plan.md)  
**Out of scope:** Mandating a second model/runtime product; PBT-as-core correctness; AFK automation

## Problem

Agents that implement and self-grade under-report defects. Industry harness practice separates **generator** from **evaluator**. ADSK’s `/review` exists but does not encode a refute-minded, separate-evaluate posture strongly enough.

## Success criteria

1. `/review` and SDD review phase require an evaluate posture distinct from implement self-check.
2. Bugfix reviews check the Unchanged (KEEP) fence, not only the fix.
3. Agents must not treat implement-session self-grade as “done” without a review pass (Medium+).
4. Eval covers “do not self-grade as done without review.”

## Assumptions

1. Protocol + Cursor `/review` is enough — no second-runtime product.
2. Absorb into `spec-driven-workflow` (`references/review-evaluator.md` + thin command/skill updates).
3. Verify remains fail-closed (`project-cmds`); review is an additional quality gate, not a substitute for verify.

## Requirements

### REQ-EV-001 — Generator ≠ evaluator protocol

`references/review-evaluator.md` MUST instruct:

- Treat `/review` as a **separate evaluate pass** after implement (new session or explicit posture switch preferred).
- Adopt a **refute-minded** stance: try to falsify “done,” not confirm it.
- Do not claim Medium+ work done solely from the implement session’s self-check.

### REQ-EV-002 — Review checklist (minimum)

Review MUST check at least:

- Spec / REQ compliance (or delta vs stated intent)
- Regression fence when a bugfix Unchanged section exists
- Security-sensitive paths (auth, secrets, money, PII, destructive ops) when in scope
- Test coverage vs REQs (or justified non-behavioral exception)
- Fail-closed verify already run (or block “done” if missing)
- Docs / README drift when user-facing surface changed (CLI, install, profiles/packs, Quick Start): flag and hand off to `/update-readme` / `readme-authoring`; do not require a full README rewrite inside `/review` unless the user asks

### REQ-EV-003 — Skill + `/review` wiring

`SKILL.md` Review step and `/review` command MUST require the evaluator posture and point at `review-evaluator.md`. `commands-reference.md` `/review` section MUST match.

### REQ-EV-004 — Bugfix fence in review

`bugfix-workflow.md` (and/or review reference) MUST state that review fails closed if Unchanged/KEEP items were not checked.

### REQ-EV-005 — Eval coverage

Add an output eval asserting that implement self-grade alone is insufficient and a separate `/review` evaluate pass is required for Medium+.

## Test strategy

| REQ | Check |
|-----|-------|
| EV-001..004 | Evidence review of reference + SKILL + commands |
| EV-005 | `evals/evals.json` case |
| Shared | sync-adsk kit + skill CI |

## Acceptance

Matches plan P0-B checklist in `.cursor/plans/harness-p0-handoff-evaluator.plan.md`.
