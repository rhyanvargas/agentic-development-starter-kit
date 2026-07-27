# Agent Instructions — The Agentic Development Starter Kit (ADSK)

This repository is the **kit source** (package + optional Cursor wiring).

**Adopters adding ADSK to an app:** follow [docs/using-adsk.md](docs/using-adsk.md) — install into `.agents/skills/`, not a root `skills/` folder. Org rules/policies (survive kit updates): [docs/customizing-org-rules.md](docs/customizing-org-rules.md).

## Product direction (adopter)

- **Contract:** [docs/product/create-adsk.md](docs/product/create-adsk.md) — kit **profile** adoption, not a skills marketplace.
- **Profiles:** [`profiles.json`](profiles.json) (core / delivery / maintainer / skills-only).
- **Rule:** [`.cursor/rules/adopter-product/`](.cursor/rules/adopter-product/) — do not invent skill-picker UX that competes with skills.sh.
- **Adopter CLI:** `npx create-adsk` ([`packages/create-adsk`](packages/create-adsk)) — wraps `npx skills` + Cursor adopter sync; living spec [`.cursor/docs/specs/create-adsk.md`](.cursor/docs/specs/create-adsk.md).
- **Alternate:** `npx skills add …` and/or `scripts/sync-adsk.sh adopter --from <kit>` (see using-adsk).

## When the user asks to sync ADSK

Do not hand-copy skill trees or Cursor files.

| Context | Run |
|---------|-----|
| **This kit repo** | `./scripts/sync-adsk.sh kit` (optional: `./scripts/sync-adsk.sh self-check`) |
| **Adopter app with `.adsk/config.json`** | `npx create-adsk update` (or `status`) |
| **Adopter app (script path)** | Resolve kit checkout → `<kit>/scripts/sync-adsk.sh adopter --from <kit>` from the app root |

Playbook: [`.cursor/commands/sync-adsk.md`](.cursor/commands/sync-adsk.md). Dual-audience steps: [docs/upgrading.md](docs/upgrading.md).

## Kit layout (this repo)

- **Package source:** `skills/<name>/` (Agent Skills `SKILL.md` — what `npx skills add` ships)
- **Discovery links (do not duplicate trees):**
  - `.agents/skills/<name>` → `../../skills/<name>`
  - `.cursor/skills/<name>` → `../../skills/<name>`
- **Cursor wiring:** `.cursor/commands/`, `.cursor/rules/` — thin wrappers; reference skills, don’t copy playbooks
- **Sync script:** [`scripts/sync-adsk.sh`](scripts/sync-adsk.sh)

Prefer:

| Artifact | Use for |
|----------|---------|
| **Rules** | Stable constraints and quality gates |
| **Commands** | User-invoked multi-step `/` workflows (thin wrappers) |
| **Skills** | Deep reusable playbooks + `references/` + `evals/` |

Lean steering: keep always-on text short; move procedure depth into skills (see [docs/skill-authoring.md](docs/skill-authoring.md)). HITL vs AFK: [docs/product/agent-autonomy.md](docs/product/agent-autonomy.md).

## Repo intent

- Keep docs concise and evidence-based (link to real file paths).
- When changing workflow behavior, update the skill **and** any thin command that invokes it.
- New first-party skills: add under `skills/<name>/`, then sync (`./scripts/sync-adsk.sh kit` or ask the agent / `/sync-adsk`).
- Adopter Cursor updates: `adopter --from <kit>` (see [docs/using-adsk.md](docs/using-adsk.md)).
- Recommended upstream skills are listed in `recommended-skills.json` — install in **adopter apps** only. Never commit real folders under `.agents/skills/` or `skills-lock.json` in this kit (discovery = symlinks to `skills/` only).
- Optional product discovery → delivery loop: [docs/product-value-loop.md](docs/product-value-loop.md) (upstream skills + ADSK SDD).

## Authoring & evals

Follow [docs/skill-authoring.md](docs/skill-authoring.md) and [docs/evaluating-skills.md](docs/evaluating-skills.md)
(aligned with [agentskills.io](https://agentskills.io)).

**When creating or editing any skill**, apply **`skill-optimizer`** (validate, lean `SKILL.md`, progressive disclosure, trigger + output evals). Cursor: rule `.cursor/rules/skill-authoring/`, command `/optimize-skill`.

## Testing note

Executable tooling:

- Smoke: `./scripts/sync-adsk.sh self-check`
- create-adsk: `npm test -w create-adsk` (see `.cursor/rules/project-cmds/`)

When adding executable code, keep exact verify commands in `project-cmds` and map spec requirements to tests where applicable.
