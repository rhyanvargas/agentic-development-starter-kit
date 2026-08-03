![Agentic Development Starter Kit](https://raw.githubusercontent.com/rhyanvargas/agentic-development-starter-kit/main/assets/social-preview.png)

# create-adsk

[![npm](https://img.shields.io/npm/v/create-adsk.svg)](https://www.npmjs.com/package/create-adsk)
[![node](https://img.shields.io/node/v/create-adsk.svg)](https://www.npmjs.com/package/create-adsk)
[![Socket Badge](https://socket.dev/api/badge/npm/package/create-adsk)](https://socket.dev/npm/package/create-adsk)

Adopt agent skills, Cursor commands, and team profiles — versioned in your repo. Not a skills marketplace.

(`create-adsk` applies an ADSK **profile**: skills via the skills CLI plus optional Cursor commands/rules.)

## Quick Start

### Interactive

```bash
npx create-adsk
```

Follow the prompts. You pick a **profile** (kit depth), optionally select **packs** (`product-value-loop`, `engineering-methods`), then the CLI installs skills, syncs Cursor commands when the profile includes them, and writes `.adsk/config.json`.

Profile skills are first-party ADSK (include `evals/`). Packs install upstream skills as those authors ship them — often without an ADSK-style `evals/` folder. Details: [`docs/using-adsk.md`](../../docs/using-adsk.md#5-evaluating-skills-adopters).

| Profile       | You get                                                                |
| ------------- | ---------------------------------------------------------------------- |
| `core`        | Spec-driven workflow + Cursor commands                                 |
| `delivery`    | Core + solution architecture + DevOps strategy + release automation    |
| `maintainer`  | Delivery + skill/README/PR authoring + supply-chain gate + stock rules |
| `skills-only` | All first-party skills; no `.cursor/` writes                           |

Source: [`profiles.json`](../../profiles.json). Contract: [`docs/product/create-adsk.md`](../../docs/product/create-adsk.md).

### Non-interactive

```bash
npx create-adsk --profile delivery --yes
```

| Flag                    | Meaning                                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------------------- |
| `--profile <id>`        | Choose a profile without prompting                                                                    |
| `--yes` / `-y`          | Skip prompts (`core` if `--profile` is omitted; packs off unless `--packs` / `--with-optional-packs`) |
| `--packs <ids>`         | Comma-separated pack IDs (e.g. `engineering-methods`)                                                 |
| `--with-optional-packs` | Include all packs                                                                                     |

See `npx create-adsk --help` for the full option list.

## Commands

```bash
npx create-adsk          # init (interactive; default)
npx create-adsk update   # refresh from .adsk/config.json
npx create-adsk status   # profile + drift (exit 1 if drift) + overlap report
npx create-adsk overlaps # scan known skill/command collisions (advisory)
```

`status` and `overlaps` share defaults when `.adsk/config.json` exists (post-sync = content vs stock). Use `overlaps --commands pre-sync` for a pre-overwrite path preview. Reports label the mode.

Other useful flags: `--dry-run`, `--scope project|global`, `--force-rules`, `--target <dir>`. Pack docs: [`docs/engineering-methods.md`](../../docs/engineering-methods.md), [`docs/product-value-loop.md`](../../docs/product-value-loop.md).

**Org rules:** put company policy in `.cursor/rules/org-*/` in the app — `update` does not overwrite those folders. Avoid `--force-rules` unless you intend to reset stock rules. Guide: [`docs/customizing-org-rules.md`](../../docs/customizing-org-rules.md).

### Windows + pnpm note

When `create-adsk` is launched via outer `npx`, it prefers `node <npm_execpath> exec -- …` over a nested `npx` so skills refresh does not depend on project-local `node_modules/npm` (absent under pnpm). If you still hit nested-npx errors on an older release, run `node path/to/create-adsk/dist/cli.js update` or use the kit `sync-adsk.sh adopter` path.

## Two tools

| Tool                  | Owns                                                 |
| --------------------- | ---------------------------------------------------- |
| **`npx skills`**      | Skill folders in `.agents/skills/`                   |
| **`npx create-adsk`** | ADSK profile (skills + Cursor + `.adsk/config.json`) |

## Local kit path (optional)

Developing against a checkout instead of the published package:

```bash
npx --yes /path/to/agentic-development-starter-kit/packages/create-adsk
```

(`npx --yes` skips the npx install prompt for that path — not the same as create-adsk `--yes`.)

## Develop in this monorepo

```bash
# from kit root
./scripts/prepare-create-adsk-snapshot.sh
cd packages/create-adsk && npm install && npm test && npm run build
node dist/cli.js --help
```

## Releases (kit vs npm)

Kit GitHub releases (`v*`) and this npm package are **independent**.

| You want…                      | Do this                                                              |
| ------------------------------ | -------------------------------------------------------------------- |
| Land code on GitHub            | PR → green `tier1` → merge to `main`                                 |
| Kit changelog / GitHub Release | Merge the release-please PR when ready                               |
| New `npx create-adsk` on npm   | Bump `package.json` version on `main`, then tag `create-adsk-vX.Y.Z` |

Full workflow: [`docs/RELEASE.md`](../../docs/RELEASE.md). Publishing uses [Trusted Publishing](https://docs.npmjs.com/trusted-publishers/) via [`.github/workflows/publish-create-adsk.yml`](../../.github/workflows/publish-create-adsk.yml).
