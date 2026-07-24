---
name: supply-chain-gate
description: >-
  Triage Socket / supply-chain PR failures, decide merge vs block, and harden
  dependency changes before merge or npm publish. Use when Socket fails, a PR
  adds npm deps, supply-chain check, Socket alerts, /setup-socket, or “can I
  add this package”. Do not use for Dependabot YAML setup (dependabot skill),
  general npm install hardening primers (npm-security-best-practices), full
  DevOps strategy, or release-please wiring (release-automation).
---

# Supply Chain Gate

Keep merges and publishes **policy-clean** under Socket + npm audit — not chase
literal 100s on every package-health gauge when the product needs `fs` / spawn.

## Principles

- **Gates over vanity scores** — block malware, install scripts, exotic deps;
  monitor expected CLI capabilities (filesystem, shell for `create-adsk`).
- **Evidence first** — read the Socket PR comment / Alerts list before changing code.
- **No new High risk without justification** — document in the PR if you must.
- **Pins for published packages** — exact versions on `create-adsk` production deps.

## Procedure

### 1. Classify the ask

| Ask | Load |
|-----|------|
| Socket CI / PR comment red | `references/alert-triage.md` |
| Wire or refresh Socket Actions + policy | `references/socket-github-actions.md` then `references/policy-allowlist.md` |
| Propose a new or upgraded npm dependency | `references/dependency-intake.md` |
| Pre-publish hygiene for `create-adsk` | `references/publish-hygiene.md` |

### 2. Decide

1. Map each alert to **block / warn / monitor** using `references/policy-allowlist.md`
   (or `SECURITY.md` → “Socket policy” in this kit).
2. Fix blockers (remove script, replace dep, pin version, drop git URL) **or**
   stop and ask the user before adding a policy exception.
3. Re-run evidence: Socket check green, and `npm ci && npm audit --audit-level=high`
   when the change touches the lockfile.

### 3. Report before done

- [ ] Alert types listed with block/warn/monitor stance
- [ ] **Policy source cited** — `references/policy-allowlist.md` and/or repo `SECURITY.md` (Socket policy section); do not triage by vibes alone
- [ ] Code or policy change named (or explicit “no change; cool-down only”)
- [ ] Manual Socket dashboard / secret steps called out if still required
- [ ] Near-miss: hand off Dependabot YAML, release-please, or DevOps strategy

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/alert-triage.md` | Socket PR/CI failed or Alerts tab needs interpretation |
| `references/policy-allowlist.md` | Setting or applying block vs warn for this repo |
| `references/socket-github-actions.md` | Adding/fixing `.github/workflows/socket.yml` or API secret |
| `references/dependency-intake.md` | Adding or bumping a dependency |
| `references/publish-hygiene.md` | Before publishing `create-adsk` (or similar CLI) |

`/setup-socket` is a thin Cursor wrapper that invokes this skill.

## Near-miss handoff

- Dependabot config → upstream `dependabot` skill
- npm ignore-scripts / lockfile hardening primer → `npm-security-best-practices`
- Branching / envs / promotion → `devops-strategy-facilitator`
- Changelog / release-please → `release-automation`
