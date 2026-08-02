# Bugfix: Node DEP0190 — args + shell:true

## Overview

`create-adsk` spawns `npx`/`npm` on Windows with `shell: true` **and** an args array, which triggers Node DEP0190 and is the insecure API shape (args are concatenated, not escaped). Tracking: https://github.com/rhyanvargas/agentic-development-starter-kit/issues/77

## Current behavior (defect)

- WHEN `defaultRunCommand` runs on win32 for `npx`/`npm`, THEN it calls `spawn(command, args, { shell: true })`.
- WHEN Node ≥ 22.15 / 23.11 runs that path, THEN DEP0190 is emitted; future majors may remove support.

## Expected behavior (correct)

- REQ-FIX-001: WHEN spawning a child process, THEN the package SHALL NOT pass a non-empty `args` array together with `shell: true` (or `shell: <path>`).
- REQ-FIX-002: WHEN platform is not win32, OR the command is not an npm/npx `.cmd` shim, THEN spawn SHALL use `shell: false` with a real argv array.
- REQ-FIX-003: WHEN win32 must run `npx`/`npm` (`.cmd`), THEN spawn SHALL go through `cmd.exe /d /s /c` with `shell: false` and a single escaped command-line string (or equivalent single-string shell form with explicit escaping) — never args + shell:true.
- REQ-FIX-004: WHEN argv elements contain spaces or shell metacharacters (`&`, `|`, `;`, quotes, etc.), THEN Windows escaping SHALL keep them as literal arguments (no injection into extra commands).

## Unchanged behavior (regression fence)

- REQ-KEEP-001: WHEN platform is win32, THEN `npx`/`npm` SHALL still resolve to the `.cmd` shim path (CVE-2024-27980 / ENOENT/EINVAL avoidance).
- REQ-KEEP-002: WHEN dryRun is true, THEN no process is spawned.
- REQ-KEEP-003: WHEN spawn fails with ENOENT/EINVAL, THEN error messaging SHALL still mention Windows/`npx` guidance.
- REQ-KEEP-004: Argv builders (`buildSkillsAddArgv`, etc.) SHALL keep producing the same argv arrays.

## Test strategy

- Unit: resolve spawn invocation never returns `shell: true` with args; win32 npx uses cmd.exe; metacharacter args are quoted.
- Unit: non-Windows unchanged (npx + shell false).
- `npm test -w create-adsk`.
