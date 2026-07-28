# /sync-adsk

Sync ADSK skills discovery links and/or Cursor wiring by running `scripts/sync-adsk.sh`.

## Usage

```
/sync-adsk
/sync-adsk --dry-run
/sync-adsk --from /path/to/agentic-development-starter-kit
```

## Behavior

When the user asks to sync ADSK, update kit Cursor artifacts, refresh skills, or run `/sync-adsk`, **run the script** (do not re-copy files by hand).

### 1. Detect context

| Context | Signals | Command |
|---------|---------|---------|
| **Kit repo** | `scripts/sync-adsk.sh` + package source `skills/*/SKILL.md` exist in the workspace | `./scripts/sync-adsk.sh kit` |
| **Adopter app (create-adsk)** | `.adsk/config.json` present | `npx create-adsk update` (prefer over script) |
| **Adopter app (script path)** | App uses `.agents/skills/` (no kit `skills/` package tree), or user wants Cursor `/` commands updated without create-adsk | `<kit>/scripts/sync-adsk.sh adopter --from <kit>` from the **app root** |

### 2. Kit maintainer path

1. From the kit repo root, run:
   ```bash
   ./scripts/sync-adsk.sh kit
   ```
2. After adding/removing a first-party skill, this is required so `.agents/skills/` and `.cursor/skills/` match `skills/`.
3. Optional smoke: `./scripts/sync-adsk.sh self-check`.
4. Report which symlinks were linked or removed.

### 3. Adopter path

**If `.adsk/config.json` exists:** run `npx create-adsk update` (and `status` if useful). Skip the kit-clone script path unless the user asks for it.

**Otherwise (script path):**

1. Resolve a kit source (`--from`):
   - Use the path the user gave, or
   - Reuse a known local checkout, or
   - Clone once: `git clone https://github.com/rhyanvargas/agentic-development-starter-kit.git` to a temp or cache dir.
2. From the **app** root, run:
   ```bash
   /path/to/adsk/scripts/sync-adsk.sh adopter --from /path/to/adsk
   ```
3. Honor user flags: `--dry-run`, `--commands-only`, `--skip-skills`, `--force-rules`, `--skills-from-path`.
4. If `npx skills` prompts for Update scope, choose **Project** for a normal app install (not Global unless they used `-g`).
5. Report what changed. Do **not** overwrite customized rules unless the user asked for `--force-rules`. Never touch specs/plans contents.
6. Surface the **overlap report** (known `do_not_add` skills, command/rule collisions). Do **not** delete conflicting artifacts unless the user confirms.

### 4. Done criteria

- Kit: discovery symlinks resolve to `skills/<name>/`.
- Adopter: stock commands under `.cursor/commands/` reference `.agents/skills/<name>`; skills refreshed unless `--skip-skills`.
- Overlap report printed (or explicit “Overlaps: none”). For each finding: recommendation + why. Offer removal only after user confirmation.
