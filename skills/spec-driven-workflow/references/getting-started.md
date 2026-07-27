# Getting Started

Set up ADSK’s spec-driven workflow in your project.

## Prerequisites

- An Agent Skills–compatible agent (Cursor, Claude Code, etc.)
- A project to work with (new or existing)

## Installation

Adopter guide (install, ask-agent sync, Cursor, custom skills): [docs/using-adsk.md](../../../docs/using-adsk.md).  
Kit maintainers: [docs/upgrading.md](../../../docs/upgrading.md#kit-maintainers).

### In your app (recommended)

```bash
npx skills add rhyanvargas/agentic-development-starter-kit
```

Skills land in `.agents/skills/`. You can ask the agent “Sync ADSK” (it should run `scripts/sync-adsk.sh`; adopters need a kit checkout). Skills-only updates: `npx skills update` → **Project**. See [docs/using-adsk.md](../../../docs/using-adsk.md).

### Global (all projects)

```bash
npx skills add rhyanvargas/agentic-development-starter-kit -g
```

Updates for a global install: `npx skills update` → **Global** (or **Both** if you also have a project copy).

### Use this kit repo directly

```bash
git clone https://github.com/rhyanvargas/agentic-development-starter-kit.git
cd agentic-development-starter-kit
```

Open in Cursor and run `/quick-start`, or activate `spec-driven-workflow`.

## First run

### Where truth lives (checklist)

After `/quick-start` (or equivalent setup), confirm:

| Item | Where |
|------|--------|
| Spec/plan artifact home | `.cursor/docs/specs` + `.cursor/plans` **or** `docs/specs` + `docs/plans` (see `artifact-homes.md`) |
| Verify commands | `.cursor/rules/project-cmds/` (or portable project verify docs) — **required before claiming done** |
| Skills discovery | `.agents/skills/` |
| Next command | Greenfield → `/draft-spec`; brownfield → `/extract-spec` |

If verify is missing, run `/quick-start` or set `project-cmds` — do not claim implement “done” without it (fail-closed).

### Brownfield (existing projects)

1. Confirm ADSK skills are available
2. `/quick-start` (Cursor) or follow `references/brownfield-workflow.md`
3. `/extract-spec path/` (or write a current-behavior spec)
4. `/draft-spec` → plan / implement / review by size

### Greenfield (new projects)

1. `/quick-start` (or set verify commands in project rules)
2. `/draft-spec "your first feature"`
3. Follow `references/greenfield-workflow.md`

## Verify setup

1. Agent discovers `spec-driven-workflow` (and `solution-architecture` / `devops-strategy-facilitator` if installed)
2. Cursor commands (optional): `/draft-spec`, `/plan-impl`, `/implement-spec`, `/review`, `/extract-spec`, `/quick-start`, `/sync-adsk`
3. In an **app** after CLI install: `.agents/skills/` has the skill folders
4. In **this kit repo**: `skills/` is package source; `.agents/skills/` and `.cursor/skills/` link to it
5. Checklist above is complete (artifact home, verify location, skills path, next command)

## Avoid overlapping SDD skills

Do **not** also install parallel “spec-driven” / PRD packs alongside ADSK — they compete for the same triggers and use different paths/templates. Examples (see `do_not_add.overlapping-sdd` in repo `recommended-skills.json`):

- Addy Osmani `spec-driven-development`, Warp `spec-driven-implementation`
- Matt Pocock `to-prd` / `to-spec` / `to-tickets` (`to-prd` was renamed to `to-spec`; skills.sh may still list the old name)
- GitHub `create-specification`

**Use instead:** ADSK `spec-driven-workflow` as the specify→ship spine; optional `engineering-methods` (`writing-plans`, TDD, systematic-debugging) for plan depth; optional `product-value-loop` for discover/prioritize/roadmap. Do not install `to-prd` for “product requirements” — that skill synthesizes chat into tracker tickets, which is a different job from continuous discovery.

## Next steps

- [Greenfield Workflow](greenfield-workflow.md)
- [Brownfield Workflow](brownfield-workflow.md)
- [Commands Reference](commands-reference.md)
- [Problem Size Guide](problem-size-guide.md)
- [docs/using-adsk.md](../../../docs/using-adsk.md)
