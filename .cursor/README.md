# `.cursor/` (Cursor integration for ADSK)

Optional Cursor wiring for **The Agentic Development Starter Kit (ADSK)**.

## What’s here

| Path | Purpose |
|------|---------|
| `.cursor/commands/` | Slash commands — thin wrappers over skills |
| `.cursor/rules/` | Project Rules (`RULE.md`) — quality gates |
| `.cursor/skills/` | Relative symlinks → `../../skills/` (Cursor discovery) |
| `.cursor/templates/` | Copy-paste starters for new rules (`rule-templates.md`) |
| `.cursor/docs/specs/` | Generated feature specs (Cursor default; portable: `docs/specs/`) |
| `.cursor/plans/` | Implementation plans (Cursor default; portable: `docs/plans/`; YAML `todos` required) |

### Commands (shipped)

| Command | Skill / role |
|---------|----------------|
| `/quick-start`, `/draft-spec`, `/plan-impl`, `/implement-spec`, `/review`, `/extract-spec` | `spec-driven-workflow` |
| `/design-architecture` | `solution-architecture` |
| `/design-devops-strategy` | `devops-strategy-facilitator` |
| `/setup-releases` | `release-automation` |
| `/setup-socket` | `supply-chain-gate` |
| `/create-pr` | `pull-request-authoring` |
| `/optimize-skill` | `skill-optimizer` |
| `/update-readme` | `readme-authoring` |
| `/run-skill-evals` | Skill eval harness (maintainer) |
| `/sync-adsk` | Runs [`scripts/sync-adsk.sh`](../scripts/sync-adsk.sh) |

### Rules (shipped)

`project`, `project-cmds`, `testing`, `cursor-artifacts`, `skill-authoring`, `adopter-product`

### Skills (discovery)

Symlinks only (same first-party skills as `.agents/skills/`): `spec-driven-workflow`, `solution-architecture`, `devops-strategy-facilitator`, `release-automation`, `skill-optimizer`, `readme-authoring`, `supply-chain-gate`, `pull-request-authoring`.

## Why

Keep slash commands and rules thin; playbooks live in `skills/<name>/`. In this kit, `.cursor/skills/` and `.agents/skills/` both point at package source — do not duplicate trees.

## How to sync

**Ask the agent:** “Sync ADSK” or `/sync-adsk` — it should run the script (not hand-copy). Adopters need a kit checkout path or clone.

```bash
# adopter app:
/path/to/adsk/scripts/sync-adsk.sh adopter --from /path/to/adsk

# kit maintainers:
./scripts/sync-adsk.sh kit
```

Step-by-step: [`docs/using-adsk.md`](../docs/using-adsk.md) (adopters), [`docs/upgrading.md`](../docs/upgrading.md) (both).

## Gotchas

- After adding a first-party skill under `skills/`, run `./scripts/sync-adsk.sh kit` so `.cursor/skills/<name>` is linked.
- Adopter sync rewrites command skill paths to `.agents/skills/` (app layout); kit commands may still reference kit-relative discovery.
- Do not commit vendored upstream skill trees into this kit’s discovery folders.
