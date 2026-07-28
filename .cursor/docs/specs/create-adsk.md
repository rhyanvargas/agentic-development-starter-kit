# create-adsk — adopter CLI

## Overview

Ship `npx create-adsk` so app teams can adopt ADSK as a **versioned profile** (skills via the skills CLI + optional Cursor wiring via existing adopter sync), without competing with skills.sh as a marketplace.

Product contract: [`docs/product/create-adsk.md`](../../../docs/product/create-adsk.md).  
Profiles: [`profiles.json`](../../../profiles.json).

**Status:** CLI implemented in [`packages/create-adsk`](../../../packages/create-adsk). **Live on npm** as `create-adsk@0.2.0` (verify: `./scripts/verify-create-adsk-registry.sh --npx`). Registry publish workflow: [`.github/workflows/publish-create-adsk.yml`](../../../.github/workflows/publish-create-adsk.yml) (OIDC Trusted Publishing). Maintainer runbook: [`docs/RELEASE.md`](../../../docs/RELEASE.md). Bootstrap plan (complete): [`.cursor/plans/create_adsk_npm_first_publish.plan.md`](../../plans/create_adsk_npm_first_publish.plan.md). Product plan: [`.cursor/plans/create-adsk.plan.md`](../../plans/create-adsk.plan.md).

**Related:** Post-adopt overlap scan — [adopter-overlap-scan.md](adopter-overlap-scan.md) · [plan](../../plans/adopter-overlap-scan.plan.md) (implemented: `create-adsk overlaps` / status section / sync-adsk adopter report).

## Assumptions

- [x] Package name / bin: `create-adsk` (invoked as `npx create-adsk`)
- [x] Skill transport remains `npx skills add|update` against `rhyanvargas/agentic-development-starter-kit`
- [x] Cursor sync reuses [`scripts/sync-adsk.sh`](../../../scripts/sync-adsk.sh) `adopter` (or a thin port with the same flags/behavior)
- [x] Four profiles and defaults match `profiles.json` exactly
- [x] Kit-maintainer `kit` mode stays out of the CLI
- [x] npm layout: `packages/create-adsk` (not repo-root bin)
- [x] Cursor artifacts: vendored `kit-snapshot/` at pack time; no manual kit clone for update (REQ-008)
- [x] skills CLI selective add: `npx --yes skills add <kit_source> --skill <name>… -y` (+ `-g` when scope=global)

## Requirements

### Functional

- [x] REQ-001: `npx create-adsk` (and `init`) interactively selects a profile from `profiles.json` (`core` | `delivery` | `maintainer` | `skills-only`) — not a free-form multi-select of arbitrary skills.
- [x] REQ-002: After profile choice, optionally select **workflow packs** from `optional_packs.packs` in `profiles.json` (multiselect; defaults off). Packs are methodology contracts (`product-value-loop`, `engineering-methods`), not a skill picker. Non-interactive: `--packs <ids>` or `--with-optional-packs` (all). Config stores pack IDs in `optionalPacks`.
- [x] REQ-003: Skill installation shells out to `npx skills add` with `--skill` flags for the profile’s skill list (and `-y` / non-interactive when `--yes`).
- [x] REQ-004: When profile `cursor` is `commands`, sync Cursor commands into the target app (path rewrite to `.agents/skills/<name>`), reusing adopter sync behavior.
- [x] REQ-005: When profile `rules` is `stock`, add stock rules add-if-missing (same set as `sync-adsk.sh`); never overwrite existing rules unless `--force-rules`.
- [x] REQ-006: When profile is `skills-only` (`cursor: none`), perform no `.cursor/commands` or `.cursor/rules` writes.
- [x] REQ-007: Write `.adsk/config.json` with at least: `version`, `profile`, `cursor`, `rules`, `scope`, `kitRef`, `optionalPacks`.
- [x] REQ-008: `npx create-adsk update` refreshes skills and re-syncs Cursor artifacts according to the saved config (skip Cursor when `cursor` is `none`).
- [x] REQ-009: `npx create-adsk status` prints installed profile, kit ref, cursor/rules mode, and obvious drift (e.g. missing skills from profile).
- [x] REQ-010: Support `--yes` (non-interactive defaults), `--dry-run`, and `--scope project|global` (default project).
- [x] REQ-011: Non-interactive profile selection via `--profile <id>` for CI/scripts.

### Non-Functional

- [x] REQ-012: Must not implement a third-party or registry skill browser.
- [x] REQ-013: Must not expose `sync-adsk.sh kit` (maintainer symlink mode).
- [x] REQ-014: Docs and CLI help state the two-tool model (skills = folders; create-adsk = kit profile).
- [x] REQ-015: On Windows, skill install/update must spawn `npx.cmd` / `npm.cmd` **with `shell: true`** so adopters do not hit `spawn npx ENOENT` or CVE-2024-27980 `spawn EINVAL` (`.cmd` without shell).

## Acceptance Criteria

- Given a clean app repo, when the user runs `npx create-adsk --profile delivery --yes`, then the delivery profile skills from `profiles.json` are installed under `.agents/skills/` (including `solution-architecture`), Cursor stock commands are present with `.agents/skills/` paths, `.adsk/config.json` records `delivery`, and no third-party catalog was shown.
- Given `skills-only`, when init completes, then first-party skills are installed and `.cursor/commands` was not created/updated by create-adsk.
- Given an existing `.adsk/config.json`, when the user runs `update`, then skills refresh and Cursor re-sync matches the saved profile without requiring a manual kit clone path from the user.
- Given the question “why not just npx skills?”, when reading CLI/README help, then the answer is kit profile + Cursor wiring in one command — not “a menu of skills.”

## Test Strategy

- REQ-001–011: CLI integration tests in `packages/create-adsk/test/*.integration.test.ts` (temp dir + fake skills runner).
- REQ-012–014: Golden help text in `packages/create-adsk/test/help.test.ts`.
- REQ-015: `resolveSpawnSpec` unit tests in `packages/create-adsk/test/skills-args.test.ts`.
- Verify: `npm test -w create-adsk` and `./scripts/sync-adsk.sh self-check`.

## Boundaries

- Always: Read profiles from `profiles.json`; wrap skills CLI; wrap adopter sync for Cursor.
- Ask first: Changing profile skill membership; renaming the npm package.
- Never: Skill marketplace UX; kit symlink mode; inventing skill lists that diverge from `profiles.json`.

## Constraints

- Reuse adopter flags/behavior where applicable: `--commands-only`, `--skip-skills`, `--rules`, `--force-rules`, `--dry-run`, `--from` / kit ref resolution.
- Do not overwrite adopter specs/plans content (same as current sync script).
- Keep `recommended-skills.json` as the source for optional upstream packs.

## Implementation decisions (locked in plan)

Resolved in [`.cursor/plans/create-adsk.plan.md`](../../plans/create-adsk.plan.md):

| Topic | Decision |
|-------|----------|
| Package layout | `packages/create-adsk`, npm name `create-adsk` |
| Cursor artifacts | Vendor kit snapshot into package; TS port of adopter sync; `kitRef` records snapshot identity |
| skills CLI flags | `--skill` per skill, `-y` / `--yes`, `-g` for global; update via `skills update -y` (`-p`/`-g` when scoped) |

Out of v1: live `--from` kit override. npm registry publish workflow is in-repo; first public release still requires the one-time npm Trusted Publisher bootstrap in [`docs/RELEASE.md`](../../../docs/RELEASE.md).
