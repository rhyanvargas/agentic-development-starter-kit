# Installing and upgrading ADSK

Two audiences. Follow the section that matches your role.

| Role | Start here |
|------|------------|
| **Adopter** (using ADSK in an app) | [using-adsk.md](using-adsk.md) |
| **Kit maintainer** (this repository) | [Kit maintainers](#kit-maintainers) below |

---

## Ask your coding agent

Both roles can ask the agent to sync instead of running commands by hand.

| You say… | Agent should… |
|----------|----------------|
| “Sync ADSK” / `/sync-adsk` in **this kit repo** | Run `./scripts/sync-adsk.sh kit` |
| “Sync ADSK” / `/sync-adsk` in an **app** with `.adsk/config.json` | Run `npx create-adsk update` |
| “Sync ADSK” / `/sync-adsk` in an **app** (script path) | Resolve a kit checkout, then run `adopter --from <kit>` from the app root |

Details and adopter caveats (agent needs a kit path or clone): [using-adsk.md — Ask your coding agent](using-adsk.md#ask-your-coding-agent-recommended).

Command playbook: [`.cursor/commands/sync-adsk.md`](../.cursor/commands/sync-adsk.md).

---

## Adopters (apps)

Step-by-step install, Cursor sync, updates, and custom skills: **[using-adsk.md](using-adsk.md)**.

Org rules and policies (customize, survive updates): **[customizing-org-rules.md](customizing-org-rules.md)**.

**Recommended short path (profile + Cursor):**

1. `npx create-adsk` (or non-interactive: `npx create-adsk --profile delivery --yes`)
2. Later: `npx create-adsk update` / `npx create-adsk status`

**Alternate (skills / script):**

1. `npx skills add rhyanvargas/agentic-development-starter-kit`
2. Optional Cursor: keep a kit clone → ask agent to sync **or** run `scripts/sync-adsk.sh adopter --from <kit>`
3. Later updates: `git pull` the kit clone → sync again (or `npx skills update` for skills-only)

---

## Kit maintainers

Work in the **agentic-development-starter-kit** repo.

### After adding or removing a first-party skill

1. Author under `skills/<name>/` (see [skill-authoring.md](skill-authoring.md); run `skill-optimizer` / `/optimize-skill`).
2. Sync discovery links — ask the agent “Sync ADSK” / `/sync-adsk`, **or**:

   ```bash
   ./scripts/sync-adsk.sh kit
   ```

3. Confirm discovery entries are **symlinks** only (no real upstream skill folders, no `skills-lock.json`):

   ```bash
   ./scripts/sync-adsk.sh self-check
   ls -la .agents/skills .cursor/skills
   ```

4. Keep thin Cursor commands in `.cursor/commands/` pointing at the skill (no duplicated playbooks).
5. Use a Conventional Commit PR title (`feat:` / `fix:` for user-visible changes) so release-please can update [CHANGELOG.md](../CHANGELOG.md) at release time — see [RELEASE.md](RELEASE.md).

### Before a release

Follow [RELEASE.md](RELEASE.md):

- **Kit:** merge the release-please Release PR when you want a GitHub `vX.Y.Z`
- **npm (optional):** bump `packages/create-adsk` and tag `create-adsk-vX.Y.Z` only when the CLI/snapshot should ship to the registry

### Smoke / verify commands

Exact commands live in [`.cursor/rules/project-cmds/RULE.md`](../.cursor/rules/project-cmds/RULE.md):

```bash
./scripts/sync-adsk.sh self-check
./scripts/sync-adsk.sh kit --dry-run
```

---

## Product / repo names

| Item | Value |
|------|--------|
| Product | The Agentic Development Starter Kit (ADSK) |
| GitHub slug | `agentic-development-starter-kit` |
| Example clone | `https://github.com/rhyanvargas/agentic-development-starter-kit.git` |

If your remote still points at `rhyan-cursor-docs`:

1. Rename the repository in GitHub settings to `agentic-development-starter-kit`
2. Update the local remote:

   ```bash
   git remote set-url origin https://github.com/rhyanvargas/agentic-development-starter-kit.git
   ```

## Releases

Two independent tracks — full detail: [RELEASE.md](RELEASE.md).

1. **Kit updates:** PR → green `tier1` → merge to `main`. Optionally merge the release-please Release PR for a GitHub `vX.Y.Z` release.
2. **npm `create-adsk` (optional):** after CLI/snapshot changes are on `main`, bump `packages/create-adsk/package.json` version and push tag `create-adsk-vX.Y.Z` (does **not** happen automatically on merge to `main`).
