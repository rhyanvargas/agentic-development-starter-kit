# `.agents/` (skill discovery)

Per [agentskills.io](https://agentskills.io/client-implementation/adding-skills-support#where-to-scan), agents look for project skills here.

## What’s here (this kit repo)

| Entry | Kind |
|-------|------|
| `skills/spec-driven-workflow` | Symlink → `../../skills/spec-driven-workflow` |
| `skills/solution-architecture` | Symlink → `../../skills/solution-architecture` |
| `skills/devops-strategy-facilitator` | Symlink → `../../skills/devops-strategy-facilitator` |
| `skills/release-automation` | Symlink → `../../skills/release-automation` |
| `skills/skill-optimizer` | Symlink → `../../skills/skill-optimizer` |
| `skills/readme-authoring` | Symlink → `../../skills/readme-authoring` |
| `skills/supply-chain-gate` | Symlink → `../../skills/supply-chain-gate` |
| `skills/pull-request-authoring` | Symlink → `../../skills/pull-request-authoring` |

Refresh discovery links after adding a first-party skill:

```bash
./scripts/sync-adsk.sh kit
```

## Why

Package source lives under root `skills/<name>/` (what `npx skills add` ships). `.agents/skills/` is discovery only — symlinks, not copies.

## How to extend

1. Add the skill under `skills/<name>/` (with `SKILL.md`).
2. Run `./scripts/sync-adsk.sh kit` (or ask the agent / `/sync-adsk` in this repo).
3. Do **not** vendor upstream trees here. List them in [`recommended-skills.json`](../recommended-skills.json) and install in **adopter apps** — see [docs/product-value-loop.md](../docs/product-value-loop.md).

## Gotchas

- Do **not** commit real skill folders or `skills-lock.json` in this kit. Local optional installs may appear under `.agents/skills/` while you try product packs; they are gitignored and `sync-adsk.sh self-check` warns about them.
- **In your app:** `npx skills add …` installs real folders under `.agents/skills/`. To also sync Cursor commands/rules, use `scripts/sync-adsk.sh adopter` — see [docs/using-adsk.md](../docs/using-adsk.md).
