# Bugfix: status and overlaps disagree after update

## Overview

After `create-adsk update`, `status` prints `Overlaps: none` while default `overlaps` still lists stock command path collisions — adopters think overlaps cleared when they did not (or modes silently differ). Tracking: https://github.com/rhyanvargas/agentic-development-starter-kit/issues/72

## Current behavior (defect)

- WHEN an adopter has stock `.cursor/commands/` matching ADSK after update AND runs `npx create-adsk status`, THEN Overlaps reports none (post-sync / content vs stock).
- WHEN the same tree runs `npx create-adsk overlaps` with default flags, THEN every stock command basename is reported as `command-collision` (pre-sync / will overwrite).
- WHEN `create-adsk --version` runs, THEN it prints `0.1.0` even though `package.json` is `0.3.x`.

## Expected behavior (correct)

- REQ-FIX-001: WHEN `.adsk/config.json` exists, THEN default `overlaps` command/rules modes SHALL match `status` (commands `post-sync` if `cursor=commands`, else `off`; rules `post-sync` if `rules=stock`, else `off`).
- REQ-FIX-002: WHEN no config exists, THEN default `overlaps` SHALL use `commands=pre-sync`, `rules=off` (pre-adopt overwrite preview).
- REQ-FIX-003: WHEN overlap report prints, THEN it SHALL label the commands/rules scan mode so pre-sync vs post-sync is not ambiguous.
- REQ-FIX-004: WHEN `create-adsk --version` runs, THEN it SHALL print the version from `packages/create-adsk/package.json`.

## Unchanged behavior (regression fence)

- REQ-KEEP-001: WHEN `overlaps --commands pre-sync` is passed explicitly, THEN existing stock command basenames SHALL still be reported as collisions (overwrite preview).
- REQ-KEEP-002: WHEN `update` runs, THEN it SHALL CONTINUE TO report overlaps with `pre-sync` **before** Cursor sync (warn about overwrite).
- REQ-KEEP-003: WHEN `sync-adsk.sh adopter` runs the overlap helper, THEN it SHALL CONTINUE TO use `--commands post-sync --rules post-sync`.
- REQ-KEEP-004: WHEN known skill overlaps (`do_not_add`) exist, THEN status and overlaps SHALL CONTINUE TO report them regardless of command mode.
- REQ-KEEP-005: Scan remains advisory (no auto-delete); exit code of `status` still driven by drift only.

## Test strategy

- Unit/integration: after syncCursor stock commands + config, `runStatus` and default overlap modes both have zero command-collisions; explicit `pre-sync` still finds them.
- `--version` matches `package.json`.
