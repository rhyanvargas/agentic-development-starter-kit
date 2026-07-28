# Adopter overlap scan — post-adopt conflict report

## Overview

When an app adopts or updates ADSK, surface **pre-existing** skills / commands / rules that collide with kit artifacts (exact name or known functional overlap), with a concise recommendation and rationale. Do **not** auto-delete.

**Motivation:** Adopter apps often already have third-party skills (e.g. `softaworks/agent-toolkit@crafting-effective-readmes`). Sync/update installs ADSK (`readme-authoring`) without warning → trigger ambiguity. Kit already documents known pairs in [`recommended-skills.json`](../../../recommended-skills.json) `do_not_add`, but nothing consumes that catalog at adopt/update time.

**Plan:** [`.cursor/plans/adopter-overlap-scan.plan.md`](../../plans/adopter-overlap-scan.plan.md)  
**Related:** [create-adsk spec](create-adsk.md) · [product/create-adsk.md](../../../docs/product/create-adsk.md) · [`docs/using-adsk.md`](../../../docs/using-adsk.md)

**Status:** Implemented in `packages/create-adsk` (`overlaps` / `scanOverlaps`) + `scripts/sync-adsk.sh adopter` report. Verify: `npm test -w create-adsk`.

## Assumptions

- [x] `do_not_add` remains the curated source of **known** functional overlaps (extend schema for machine match)
- [x] Detection v1 is deterministic (catalog + basename collisions); NLP/trigger similarity is optional agent-only, out of CLI v1
- [x] Report is advisory by default (exit 0); optional `--strict-overlaps` may fail CI later
- [x] Destructive cleanup stays HITL — print recommendation only
- [x] Same report behavior on create-adsk path **and** `sync-adsk.sh adopter` / `/sync-adsk`

## Requirements

### Functional

- [x] REQ-001: Extend `do_not_add` entries with machine fields: at least `adsk_skill`, `skill_names[]`, `recommendation`, `reason` (keep existing `examples` / `id`). Optionally `adsk_commands[]`.
- [x] REQ-002: Shared `scanOverlaps(appRoot, snapshotRoot, opts)` inventories `.agents/skills/*/SKILL.md` (and project `skills-lock.json` provenance when present), compares to profile/first-party skills + `do_not_add`, and returns structured findings.
- [x] REQ-003: Detect **exact skill folder name** collision with an ADSK first-party skill name (report even if overwrite already occurred on this run — “was/is ADSK-owned”).
- [x] REQ-004: Detect **known functional overlap** when an installed skill name (or lockfile `@skill` slug) matches `do_not_add[].skill_names` / parsed `examples`.
- [x] REQ-005: Detect **command basename collision**: ADSK stock command about to write/overwrite an existing `.cursor/commands/<name>.md` that was not previously an identical stock file (or always report pre-existing same-name file before sync).
- [x] REQ-006: Detect **rule dir name collision** for stock rule names when rules sync is in play; never flag `org-*` as ADSK collisions.
- [x] REQ-007: Print a concise report per finding: artifact kind, existing id/source, ADSK counterpart, kind (name | known-overlap), **recommendation**, **why**. List extras with no known overlap separately (informational).
- [x] REQ-008: Run scan after successful `create-adsk` `init` and `update` (and include findings in `status` output / structured result).
- [x] REQ-009: Run equivalent scan at end of `scripts/sync-adsk.sh adopter` (reuse Node helper or shared JSON + thin matcher — prefer one implementation).
- [x] REQ-010: Update `.cursor/commands/sync-adsk.md` done criteria: surface the overlap report; offer removal only with user confirmation.
- [x] REQ-011: Never auto-delete or modify conflicting third-party skills/commands/rules as part of the scan.

### Non-Functional

- [x] REQ-012: No skills marketplace / registry browser; scan local tree + kit catalog only.
- [x] REQ-013: Unit/integration tests cover at least: `crafting-effective-readmes` vs `readme-authoring` (known overlap); missing overlap → empty findings; command same-name pre-existing file.
- [x] REQ-014: Docs pointer in `docs/using-adsk.md` (or upgrading) that adopt/update may report overlaps and how to act.

## Acceptance Criteria

- Given an app with `.agents/skills/crafting-effective-readmes` and ADSK `readme-authoring` installed, when the user runs `npx create-adsk update` (or `status`), then the report includes one known-overlap finding recommending keep `readme-authoring` / remove the softaworks skill, with reason from `do_not_add.overlapping-readme`.
- Given a clean ADSK-only install, when update/status runs, then no overlap findings (extras list empty or absent).
- Given sync via `sync-adsk.sh adopter`, when a known `do_not_add` skill is present, then the same class of warning appears before “Adopter sync complete.”
- Given a finding, when the user does nothing, then no files were deleted by the scan.

## Test Strategy

- Unit: parse `do_not_add`, match skill folder names and `org/repo@skill` example slugs.
- Integration: temp app fixture with fake skills dirs + snapshot `recommended-skills.json`; assert `scanOverlaps` / status / update stdout contains expected finding lines.
- Script path: self-check or focused fixture invoking adopter mode with a planted overlap (skills skipped OK if scan still runs on existing dirs).

## Boundaries

- Always: Curated catalog + exact name collisions; HITL cleanup; both create-adsk and script sync paths.
- Ask first: Making overlaps fail the process by default; auto-removing skills; expanding into free-form LLM similarity in the CLI.
- Never: Marketplace UX; deleting adopter content without confirmation; flagging optional packs installed via create-adsk as conflicts with themselves.

## Constraints

- Prefer extending existing `recommended-skills.json` over a second catalog file.
- Keep report short (adopter-facing); deep playbooks stay in docs/`do_not_add.reason`.
- Snapshot copy of `recommended-skills.json` must stay in sync for create-adsk.

## Open questions

1. Should `status` exit non-zero on known overlaps (like drift), or only with `--strict-overlaps`? **Lean:** advisory in v1; strict flag optional. ✅ Locked: advisory.
2. Global scope (`~/.agents/skills`): scan global tree when `scope=global`? **Lean:** yes when config says global. ✅ Implemented.
3. Heuristic SKILL.md description similarity for *unknown* extras: CLI or agent-only? **Lean:** agent-only via `/sync-adsk` follow-up; not CLI v1. ✅ Locked: agent-only.
