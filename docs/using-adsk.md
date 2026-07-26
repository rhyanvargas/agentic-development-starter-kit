# Using ADSK in your project

For people adding ADSK to an **app** (not contributing to this kit).

Skills in **your** project live under `.agents/skills/` ([agentskills.io](https://agentskills.io/client-implementation/adding-skills-support#where-to-scan)). There is no root `skills/` folder in your app.

**Engineering leads** (team standard vs skills.sh discovery): [product/for-eng-leads.md](product/for-eng-leads.md) · [product/profiles-and-packs.md](product/profiles-and-packs.md).

**Org rules & policies** (customize without losing them on update): [customizing-org-rules.md](customizing-org-rules.md).

**Kit maintainers** (this repo): see [upgrading.md](upgrading.md#kit-maintainers) and [CONTRIBUTING.md](../CONTRIBUTING.md).

### Two-tool model

| Goal                                                                | Use                                                                                                                                                                     |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Install skill folders only                                          | `npx skills add …` (section 1)                                                                                                                                          |
| Adopt ADSK as a **profile** (skills + Cursor wiring + saved config) | **`npx create-adsk`** — [`packages/create-adsk`](../packages/create-adsk); see [product/create-adsk.md](product/create-adsk.md) and [`profiles.json`](../profiles.json) |
| Cursor commands without the CLI                                     | Kit checkout + `sync-adsk.sh adopter` (section 2)                                                                                                                       |

---

## 0. Recommended: adopt a profile with create-adsk

### Interactive

```bash
npx create-adsk
```

Follow the prompts. Pick a **profile** (kit depth), then optional **packs** (methodology: `product-value-loop`, `engineering-methods`), then install. See [product/profiles-and-packs.md](product/profiles-and-packs.md).

| Profile       | What you get                                                                                                               |
| ------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `core`        | `spec-driven-workflow` + Cursor commands                                                                                   |
| `delivery`    | Core + DevOps strategy + release automation + Cursor commands                                                              |
| `maintainer`  | Delivery + skill-optimizer + readme-authoring + supply-chain-gate + pull-request-authoring + Cursor commands + stock rules |
| `skills-only` | All first-party skills; no `.cursor/` writes                                                                               |

### Non-interactive

```bash
npx create-adsk --profile delivery --yes
npx create-adsk --profile core --yes --packs engineering-methods
```

`--profile` chooses the profile; `--yes` skips prompts (`core` if you omit `--profile`). Packs: `--packs <ids>` or `--with-optional-packs` (all). Playbooks: [product-value-loop.md](product-value-loop.md), [engineering-methods.md](engineering-methods.md).

**Packs vs first-party layout:** Profile skills are **first-party ADSK** — they install with `evals/` (and usually `references/`). Optional packs pull **upstream** skills (wondelai, deanpeters, Superpowers, …) **as those authors ship them**, so many pack skills will not have an ADSK-style `evals/` folder. That is expected, not a broken install. See [§5 Evaluating skills](#5-evaluating-skills-adopters).

Later: `npx create-adsk update` · `npx create-adsk status`.  
Flags and local kit path: [`packages/create-adsk/README.md`](../packages/create-adsk/README.md).

The sections below cover skills-only installs and the script-based Cursor path.

---

## Ask your coding agent

You can ask the agent in plain language, for example:

- “Sync ADSK”
- “Update ADSK Cursor commands and skills”
- `/sync-adsk` (after Cursor wiring is installed)

If the app already has `.adsk/config.json`, prefer `npx create-adsk update`. Otherwise the agent should run [`scripts/sync-adsk.sh`](../scripts/sync-adsk.sh) — not hand-copy files.

| You are in…                        | Agent should run                                                    |
| ---------------------------------- | ------------------------------------------------------------------- |
| **This kit repo**                  | `./scripts/sync-adsk.sh kit`                                        |
| **Your app (create-adsk adopted)** | `npx create-adsk update` (or status)                                |
| **Your app (script path)**         | `<kit>/scripts/sync-adsk.sh adopter --from <kit>` from the app root |

**Script-path requirement:** the agent needs a kit checkout (path you provide, an existing clone, or it clones GitHub once). `npx skills add` installs skills only; it does **not** install the sync script into your app. After the first Cursor sync, `/sync-adsk` is available and points the agent at the same flow. `create-adsk` vendors Cursor artifacts in the package — no kit clone required for update.

---

## 1. Install skills only

### This project only (recommended for skills-only)

In your app repo:

```bash
npx skills add rhyanvargas/agentic-development-starter-kit
```

That installs ADSK skills into `.agents/skills/`.

### All your projects (global)

```bash
npx skills add rhyanvargas/agentic-development-starter-kit -g
```

Skills go to `~/.agents/skills/` instead of the repo.

### Optional: product value loop (discover → ship)

ADSK’s first-party skills cover **spec → plan → implement → review**. To add customer discovery, competitive research, prioritization, and outcome roadmaps, install the recommended product pack and follow:

**[docs/product-value-loop.md](product-value-loop.md)**

```text
Discover → Research → Prioritize → Plan → Execute → measure → Discover
```

Those upstream skills are listed under `optional` in [`recommended-skills.json`](../recommended-skills.json). Install **project-local** (team share) and/or **global** (`-g`, personal) after your trust review; do not treat them as ADSK first-party packages (they often omit ADSK `evals/` — see [§5](#5-evaluating-skills-adopters)). With create-adsk, select packs interactively or pass `--packs` / `--with-optional-packs`.

---

## 2. Optional: Cursor slash commands (script path)

Skills work without this. Prefer [section 0](#0-recommended-adopt-a-profile-with-create-adsk) when you want profile + Cursor in one step. Use this path only if you want `/draft-spec`, `/plan-impl`, `/sync-adsk`, etc. **without** create-adsk.

### Steps

1. Clone ADSK once (keep the checkout for later updates):

   ```bash
   git clone https://github.com/rhyanvargas/agentic-development-starter-kit.git ~/src/adsk
   ```

2. From **your app root**, either:

   **A. Ask your agent:** “Sync ADSK Cursor commands from `~/src/adsk`”

   **B. Run the script yourself:**

   ```bash
   ~/src/adsk/scripts/sync-adsk.sh adopter --from ~/src/adsk
   ```

3. Open the project in Cursor and try `/quick-start`.

### What the sync does

| Artifact            | Behavior                                                                               |
| ------------------- | -------------------------------------------------------------------------------------- |
| `.cursor/commands/` | Writes/updates stock ADSK commands; rewrites `skills/<name>` → `.agents/skills/<name>` |
| `.cursor/rules/`    | Adds stock rules (`skill-authoring`, `testing`, `project-cmds`) only if missing        |
| `.agents/skills/`   | Runs `npx skills update` (or `add` if none installed)                                  |
| Specs / plans       | Never overwritten; ensures empty `.cursor/docs/specs/` + `.cursor/plans/` exist        |

Useful flags: `--dry-run`, `--commands-only`, `--skip-skills`, `--force-rules`, `--rules all|none`, `--skills-from-path` (offline copy from kit `skills/`).

---

## 3. Get updates later

When ADSK ships changes, skim [`CHANGELOG.md`](../CHANGELOG.md) on GitHub, then update.

### create-adsk adopters

```bash
npx create-adsk update
npx create-adsk status
```

### Cursor wiring + skills (script path)

1. Update your kit checkout: `git -C ~/src/adsk pull`
2. From your **app** root, ask the agent “Sync ADSK” / run `/sync-adsk`, **or**:

   ```bash
   ~/src/adsk/scripts/sync-adsk.sh adopter --from ~/src/adsk
   ```

### Skills only (no Cursor wiring)

From your app repo:

```bash
npx skills update
```

If the CLI asks for **Update scope**:

| Scope       | Choose when                                                      |
| ----------- | ---------------------------------------------------------------- |
| **Project** | You installed with `npx skills add …` in this repo (recommended) |
| **Global**  | You installed with `-g`                                          |
| **Both**    | You keep the same skills in project **and** global               |

For a normal app install, pick **Project**.

`npx skills update` alone does **not** refresh Cursor commands/rules. `create-adsk update` or the sync script does. Neither overwrites customized rules unless you pass `--force-rules`.

**Org policy folders** you add (e.g. `.cursor/rules/org-security/`) are never part of the stock sync list — they survive update. Full guide: [customizing-org-rules.md](customizing-org-rules.md).

---

## 4. Add your own skill (your project only)

**Profile:** use **`maintainer`** (or `skills-only`) so `skill-optimizer` and `/optimize-skill` are available. Do not ship a company skill without that loop.

1. Create a folder under `.agents/skills/` (folder name = skill `name`):

   ```bash
   mkdir -p .agents/skills/my-company-skill
   ```

2. Add `.agents/skills/my-company-skill/SKILL.md`:

   ```markdown
   ---
   name: my-company-skill
   description: >-
     Does X for our app. Use when the user asks about Y. Do not use for Z
     (near-miss).
   ---

   # My company skill

   1. …
   ```

3. **Optimize before you ship it** (`/optimize-skill` or ask the agent to follow `skill-optimizer`):
   - Keep `SKILL.md` lean; put depth in `references/` with when-to-load conditions
   - Add `evals/trigger/eval_queries.json` (~20 should/shouldn’t queries, including near-misses)
   - Add `evals/evals.json` (2–3 cases + 1 edge) when the skill has behavior instructions
   - Validate: `npx --yes skills-ref validate ./.agents/skills/my-company-skill`

4. **Before commit (behavior change):** `/run-skill-evals .agents/skills/my-company-skill` — with-skill vs without-skill; fix assertions or instructions from the grades.

5. Restart / refresh the agent so it picks up the new skill.

**Share with the team:** commit `.agents/skills/`.  
**Keep private:** gitignore, for example `.agents/skills/my-company-skill/`.

More authoring guidance: [skill-authoring.md](skill-authoring.md).

---

## 5. Evaluating skills (adopters)

Evals are a **maintainer quality loop**, not something every app re-runs on every PR. How ADSK defines inspectable trust (skill vs delivery ground truth): [evaluating-skills.md § Ground truth](evaluating-skills.md#ground-truth-adsk).

| Situation                             | Do this                                                                       |
| ------------------------------------- | ----------------------------------------------------------------------------- |
| Trust stock first-party skills        | Read [evals/SCORECARD.md](evals/SCORECARD.md) — published with/without deltas |
| Pack / upstream skill has no `evals/` | Expected — packs install upstream as authored; do not invent stub evals       |
| Author or change a **company** skill  | `/optimize-skill` → harness + `/run-skill-evals` before ship                  |
| Changed model or major skill behavior | Re-run `/run-skill-evals` for that skill only                                 |
| Day-to-day feature PRs                | Do **not** re-benchmark; use normal `/review`                                 |

First-party ADSK skills under your profile include `evals/` when installed via `npx skills` / create-adsk. Pack skills (e.g. product-value-loop) live alongside them in `.agents/skills/` but follow upstream layout.

**Easy path:** after Cursor sync, invoke `/run-skill-evals` (thin command). Full playbook: [evaluating-skills.md](evaluating-skills.md). Kit Tier 1 CI (`check-skills-ci.sh`) only checks harness shape — pass rates come from the agent with/without loop (Tier 2).

Hard LLM pass-rate gates and `create-adsk eval` are **out of scope** until cost/flakiness baselines exist.

---

## 6. Org rules and policies (team leads)

After adopt, put organization constraints in **your app**, not by forking the kit:

1. Add `.cursor/rules/org-*/RULE.md` (and optional short `AGENTS.md`)
2. Fill `.cursor/rules/project-cmds/` with real verify commands
3. Optional: company skills under `.agents/skills/` (section 4)
4. Commit; use `npx create-adsk update` without `--force-rules` so customizations stay

How to write agent-friendly rules, what update preserves, and a checklist: **[customizing-org-rules.md](customizing-org-rules.md)**. Eng-lead mandate framing: [product/for-eng-leads.md](product/for-eng-leads.md).

---

## 7. Quick check

- Agent sees first-party skills from your profile (including `supply-chain-gate` and `pull-request-authoring` on maintainer / skills-only)
- Project install → real folders under `.agents/skills/`
- Specs/plans unchanged after update/sync
- Org rule folders (e.g. `org-*`) still present after `create-adsk update`
- Synced slash commands reference `.agents/skills/<name>` (not kit `skills/`)
- `/sync-adsk` is available if you synced Cursor commands (create-adsk or script)
- `/run-skill-evals` available when you need with/without evidence (maintainer / synced commands)
- create-adsk adopters have `.adsk/config.json` and `npx create-adsk status` is clean

---

## Notes

| Topic                | Detail                                                                                               |
| -------------------- | ---------------------------------------------------------------------------------------------------- |
| This ADSK repo       | Package source under `skills/`; not used that way in your app                                        |
| Profile adopt        | [`packages/create-adsk`](../packages/create-adsk) · [product/create-adsk.md](product/create-adsk.md) |
| Org rules / policies | [customizing-org-rules.md](customizing-org-rules.md)                                                 |
| Cursor sync (script) | [`scripts/sync-adsk.sh`](../scripts/sync-adsk.sh) `adopter`                                          |
| Ask the agent        | Preferred UX; agent runs create-adsk or the sync script (see above)                                  |
| Cursor-only skills   | `.cursor/skills/` works; prefer `.agents/skills/` for portability                                    |
| Upstream PRs         | [CONTRIBUTING.md](../CONTRIBUTING.md)                                                                |
| Releases             | [CHANGELOG.md](../CHANGELOG.md) · [RELEASE.md](RELEASE.md)                                           |
