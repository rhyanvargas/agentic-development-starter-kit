---
name: Adopter overlap scan
overview: After ADSK adopt/update/sync, deterministically detect pre-existing skills/commands/rules that collide with kit artifacts (exact name or do_not_add known overlaps) and print a concise recommendation + why — without auto-deleting.
todos:
  - id: T1
    content: "REQ-001 — Enrich do_not_add schema (adsk_skill, skill_names, recommendation); sync kit-snapshot"
    status: completed
  - id: T2
    content: "REQ-002–007,012 — scanOverlaps() + concise report formatter in create-adsk"
    status: completed
  - id: T3
    content: "REQ-008 — Hook scan into init, update, and status"
    status: completed
  - id: T4
    content: "REQ-009 — Wire scan into sync-adsk.sh adopter (shared impl)"
    status: completed
  - id: T5
    content: "REQ-010,014 — Update /sync-adsk done criteria + using-adsk docs pointer"
    status: completed
  - id: T6
    content: "REQ-011,013 — Tests (readme overlap fixture, clean install, command collision)"
    status: completed
isProject: false
---

# Adopter overlap scan — implementation plan

> **For agentic workers:** Spec REQs implemented. Spec: [`.cursor/docs/specs/adopter-overlap-scan.md`](../docs/specs/adopter-overlap-scan.md).

**Goal:** Make leftover / third-party skill and Cursor collisions visible at adopt and sync time (the `crafting-effective-readmes` vs `readme-authoring` class of problem), with recommendation + why, no silent deletes.

**Status:** Done — `packages/create-adsk/src/overlaps.ts`, `create-adsk overlaps`, hooks in init/update/status, `sync-adsk.sh` `report_adopter_overlaps`, docs + tests.

**Architecture:** Curated `do_not_add` in [`recommended-skills.json`](../../recommended-skills.json) becomes machine-matchable. One TypeScript `scanOverlaps` in `packages/create-adsk`; `init`/`update`/`status` call it; `scripts/sync-adsk.sh adopter` invokes the same helper (e.g. `node …/scan-overlaps` or `npx create-adsk status --overlaps-only` when config exists — prefer a small exported CLI/entry that works without full config for script path).

**Size:** Medium (schema + scanner + three wire-ins + tests + thin docs/command).

**Out of v1:** NLP trigger similarity in CLI; default non-zero exit on overlaps; auto-removal.

---

## Locked decisions (from open questions)

| Question | Decision |
|----------|----------|
| status exit on overlaps | Advisory (exit 0) in v1; optional `--strict-overlaps` may be added but not required for MVP |
| Global scope | When config `scope=global`, scan `~/.agents/skills` |
| Unknown-extra heuristics | Agent-only via `/sync-adsk` follow-up; CLI stays catalog + name collisions |
| Cleanup | Never auto-delete (REQ-011) |

---

## Requirements → tasks

| Requirement | Tasks |
|-------------|-------|
| REQ-001 | T1 |
| REQ-002–007, 012 | T2 |
| REQ-008 | T3 |
| REQ-009 | T4 |
| REQ-010, 014 | T5 |
| REQ-011, 013 | T6 |

---

## Tasks

### T1 — Enrich `do_not_add`

For each existing entry (`overlapping-sdd`, `overlapping-readme`):

- Add `adsk_skill`, `skill_names[]` (slugs derived from today’s `examples`), `recommendation` (`keep-adsk`), keep `reason` / `examples`.
- Optionally `adsk_commands` (e.g. `update-readme` for readme overlap).
- Mirror into `packages/create-adsk/kit-snapshot/recommended-skills.json` (or regenerate via existing snapshot script if one exists).
- Extend TS types for `RecommendedSkillsFile` / `do_not_add`.

### T2 — `scanOverlaps` + report

New module (e.g. `packages/create-adsk/src/overlaps.ts`):

1. List skill dirs under project (or global) `.agents/skills`.
2. Load first-party names from `profiles.json` union (or skills listed in snapshot).
3. Load `do_not_add` from snapshot `recommended-skills.json`.
4. Emit findings: `name-collision` | `known-overlap` | `command-collision` | `rule-collision`.
5. Format stdout block matching spec acceptance (skill, source, collides, kind, rec, why).
6. Informational: extras not in profile and not in `do_not_add`.

### T3 — create-adsk wire-in

- Call after successful skill + cursor steps in `init` and `update`.
- `status`: print overlaps section; include in `StatusResult` (e.g. `overlaps: Finding[]`) without failing exit in v1.

### T4 — sync script wire-in

- End of `mode_adopter`: run scanner against `$dest` using kit/snapshot recommended-skills + first-party skill list from kit `skills/` or `profiles.json`.
- Prefer invoking packaged/create-adsk helper so bash does not reimplement matching. If create-adsk is not installed globally, allow `node packages/create-adsk/...` from kit checkout `--from`.

### T5 — Command + docs

- `.cursor/commands/sync-adsk.md` (+ kit-snapshot copy): done criteria include “print overlap report; confirm before remove.”
- Short subsection in `docs/using-adsk.md` (adopt/update may warn on overlaps).

### T6 — Tests

- Fixture: plant `crafting-effective-readmes` → expect `overlapping-readme` finding + keep-adsk.
- Clean ADSK-only → zero known overlaps.
- Pre-existing `.cursor/commands/draft-spec.md` → command-collision finding when scanning commands.
- Verify: `npm test -w create-adsk`.

---

## Done when

- [x] Spec REQ-001–014 checked off (or explicitly deferred with note)
- [x] README overlap case from adopter incident is covered by a test
- [x] Both create-adsk and adopter script paths surface the report

## Follow-ups (not this plan)

- Grow `do_not_add` as new collisions appear
- Agent heuristic pass for unknown extras
- `--strict-overlaps` for CI
