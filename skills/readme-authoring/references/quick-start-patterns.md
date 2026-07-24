# Quick Start patterns (npm / OSS CLIs)

**When to load:** Writing or reviewing the first-screen install path for a public npm package, scaffolder (`create-*`), or CLI README — especially when the Quick Start feels dense, jargon-heavy, or flag-heavy.

## What top packages do

Evidence from widely used npm READMEs (create-next-app, create-vite, Express, Commander, execa):

| Habit | Practice |
|-------|----------|
| Heading | Prefer **`## Quick Start`** (or **Install** then Quick Start). Avoid long titles like “Use in your app (2 minutes)”. |
| Happy path | One command, zero optional flags, then **one sentence** of outcome (“Follow the prompts…”, “Creates an app…”). |
| Flags | Live under **`### Non-interactive`** (or “CI / scripts”), not in the first paragraph. |
| Alternatives | Second install story (skills-only, script path, advanced sync) goes **below** Quick Start or in linked docs — not stacked in the hero. |
| Jargon | Keep product jargon out of the first block; link to contracts/profiles for depth. |
| Monorepo roots | Often marketing + package table; detailed install lives in the **package** README (see Vite). |

Closest peers for `create-*` CLIs: [create-next-app](https://github.com/vercel/next.js/tree/canary/packages/create-next-app) and [create-vite](https://github.com/vitejs/vite/tree/main/packages/create-vite) — Interactive first, Non-interactive second, “Then follow the prompts!”

## Recommended shape (CLI / scaffolder)

```markdown
## Quick Start

### Interactive

```bash
npx my-cli
```

Follow the prompts to … [one outcome sentence].

### Non-interactive

```bash
npx my-cli --profile delivery --yes
```

| Flag | Meaning |
|------|---------|
| `--profile <id>` | … (only if evidenced in the package) |
| `--yes` | Skip prompts … (only if evidenced; do **not** add `-y` unless the CLI actually documents it) |

### Alternatives

| Goal | Path |
|------|------|
| Other install mode | short command or link |
```

**Flag hygiene:** Document only flags proven in `--help`, `package.json` bin docs, or the user’s prompt. Never invent short aliases or sibling flags “for completeness.”

## Anti-patterns

- Leading with the CI command (`--yes`, many flags) as the “recommended” path
- Explaining every flag in the same breath as the first install command
- Inventing short aliases (`-y`, `-f`, …) or extra flags not in the evidenced CLI surface
- Three install stories (CLI + skills-only + script sync) before the reader runs anything
- Headings that sound like a product brief instead of a how-to (“Use in your app…”)
- “kit shape”, “adopter”, “wiring” in the first viewport without a plain-language gloss

## Root vs package README

| File | Role |
|------|------|
| Repo root | Shortest adopt path + link to package docs |
| `packages/<cli>/README.md` | Full Interactive / Non-interactive, profile table, maintainers |

Prefer linking rather than duplicating long flag docs in both places.
