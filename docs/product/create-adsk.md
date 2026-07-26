# Product contract — create-adsk

Single source of truth for ADSK’s **adopter product**. Agents and contributors must align adopter UX with this document and [`profiles.json`](../../profiles.json). Living requirements: [`.cursor/docs/specs/create-adsk.md`](../../.cursor/docs/specs/create-adsk.md).

**Status:** CLI implemented in [`packages/create-adsk`](../../packages/create-adsk). **Live on npm** as [`create-adsk@0.2.0`](https://www.npmjs.com/package/create-adsk) — adopters run `npx create-adsk`. Registry releases use Trusted Publishing ([`publish-create-adsk.yml`](../../.github/workflows/publish-create-adsk.yml)); see [`docs/RELEASE.md`](../RELEASE.md). Alternate paths remain valid: [`docs/using-adsk.md`](../using-adsk.md) (`npx skills` alone, or `sync-adsk.sh adopter`).

---

## Job

> When I’m starting or standardizing agentic work in an app repo, I want to adopt a proven spec→ship kit with optional Cursor slash commands, so I can get a consistent team workflow (process + feedback loops, not more agent power) without assembling skills, commands, and sync scripts myself.

## One-liner

**Repo adopter for the Agentic Development Starter Kit** — workflow + Cursor wiring + versioned profile. Not a skills marketplace.

**Team framing:** Profile = kit depth; packs = methodology contracts (`product-value-loop`, `engineering-methods`). Eng-lead pitch: [for-eng-leads.md](for-eng-leads.md). Model: [profiles-and-packs.md](profiles-and-packs.md). Playbooks: [product-value-loop.md](../product-value-loop.md), [engineering-methods.md](../engineering-methods.md). Do not invent domain profiles that clone [skills.sh topics](https://www.skills.sh/topic).

## Two-tool model

| Tool | Owns | Does not own |
|------|------|----------------|
| **`npx skills`** (skills.sh) | Discover, install, update skill folders into `.agents/skills/` | Cursor commands/rules, ADSK profiles, kit trust policy |
| **`npx create-adsk`** | Apply an ADSK **profile** (skills + Cursor + config), update/status | Third-party skill catalog, kit-maintainer symlink sync |

**README answer:** Use `npx skills` to install skill folders. Use `npx create-adsk` when you want ADSK’s workflow + Cursor commands adopted as a versioned profile in your repo.

create-adsk **wraps** `npx skills` and adopter Cursor sync (same behavior as [`scripts/sync-adsk.sh`](../../scripts/sync-adsk.sh) `adopter`, against a vendored kit snapshot). It must not reimplement skill install.

---

## Profiles

Machine-readable source: [`profiles.json`](../../profiles.json).

| Profile | Skills | Cursor default | Rules default |
|---------|--------|----------------|---------------|
| **core** | `spec-driven-workflow` | Commands | None |
| **delivery** | Core + `solution-architecture` + `devops-strategy-facilitator` + `release-automation` | Commands | None |
| **maintainer** | Delivery + `skill-optimizer` + `readme-authoring` + `supply-chain-gate` + `pull-request-authoring` | Commands | Stock |
| **skills-only** | All first-party skills | None (no `.cursor/` writes) | None |

After profile choice, optional **pack** multiselect from `optional_packs.packs` in [`profiles.json`](../../profiles.json) (defaults off). Each pack expands to `entry_ids` in [`recommended-skills.json`](../../recommended-skills.json). Never a free-form skill picker. Flags: `--packs <ids>`, `--with-optional-packs` (all). See [profiles-and-packs.md](profiles-and-packs.md).

---

## Hard product rules

1. Differentiate by **kit adoption**, not skill installation.
2. Always shell out to the skills CLI for skill bytes; own only Cursor sync, profile, and pin.
3. Default Cursor commands **ON** for core / delivery / maintainer. Skills-only exists for honesty.
4. Persist `.adsk/config.json` (profile, cursor mode, kit ref, scope) so `update` is deterministic.
5. Do **not** reinvent discovery, global skill search, or “install any GitHub skill.” Point to skills.sh / `find-skills` for that.
6. **Kill criteria:** If the demo cannot answer “why not `npx skills`?” in one sentence without mentioning menus, cut scope.

---

## Non-goals

- Interactive multi-select of every first-party skill as the primary UX
- Competing with skills.sh discovery or hosting arbitrary third-party skills
- Kit-maintainer `sync-adsk.sh kit` mode behind `npx create-adsk`
- Removing the script-based `/sync-adsk` / `adopter --from` path for teams that prefer it

---

## Success metrics

- Time-to-first `/draft-spec` (or equivalent) in a fresh app under 2 minutes
- Adopters who want Cursor commands get them without a manual kit clone (~100% for non–skills-only)
- Support questions about “which path do I clone?” → near zero
- Non-goal: skills.sh download share

---

## Alternate paths

Still supported — see [using-adsk.md](../using-adsk.md):

1. **Skills only:** `npx skills add rhyanvargas/agentic-development-starter-kit` (optionally with `--skill` flags matching a profile)
2. **Script Cursor sync:** kit checkout → `scripts/sync-adsk.sh adopter --from <kit>`

`create-adsk` is the recommended first-time adopt path for profile + Cursor. Skills-only users may still use `npx skills` alone.
