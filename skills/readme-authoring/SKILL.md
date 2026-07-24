---
name: readme-authoring
description: >-
  Create, update, review, or sync README.md files with evidence from the
  codebase, matched to audience (OSS, internal, personal, config). Use when
  writing or refreshing a README, documenting a package or CLI quick start,
  fixing stale/dense install docs, or when /update-readme is invoked. Do not
  use for changelogs, release notes, API reference generation,
  CONTRIBUTING-only or AGENTS.md-only edits, marketing landing copy, or
  optimizing Agent Skills.
---

# README Authoring

Write READMEs that answer the reader’s next question — grounded in what the
repo actually does.

## Principles

- **Audience first** — OSS users ≠ new hires ≠ future-you in a config folder.
- **Evidence over invention** — claims, commands, flags, and APIs must match files or the user’s stated surface. Do not invent short aliases (e.g. `-y`) unless evidenced.
- **Shortest path to working** — one happy-path command early; flags and alternate installs below.
- **Quick Start first viewport** — prefer `## Quick Start`; interactive/zero-flag path first; Non-interactive second (see `references/quick-start-patterns.md` for npm/CLI packages).
- **Link, don’t duplicate** — deeper docs stay linked.
- **Human prose** — direct, active voice; no promotional or inflated AI tone.

## Procedure

### 1. Scope

| Clarify | Options |
|---------|---------|
| Task | Create · Add section · Update/sync · Review |
| Audience / type | OSS · Internal · Personal · Config (ask if unclear) |
| README path | Repo root or package dir (monorepo: scope analysis to that tree) |

### 2. Discover evidence

Before drafting, gather facts from the tree that owns the README:

1. Manifests / lockfiles → package manager, scripts, runtime requirements
2. Entry points / public exports (libraries) or run/deploy commands (apps/services)
3. Existing docs to cross-link (`CONTRIBUTING.md`, `AGENTS.md`, `ARCHITECTURE.md`, `docs/`)
4. Real usage: `examples/`, tests, or documented CLI — never fabricate samples

Load `references/evidence-discovery.md` when the tree is large, monorepo-scoped, or the public surface is unclear.

### 3. Diff against current README (if any)

Present a short gap list before writing:

- **Missing** — real capability undocumented
- **Stale** — documented but gone / renamed / wrong commands
- **Wrong audience** — sections that don’t match project type
- **Dense Quick Start** — flag soup, three install stories, or jargon in the first viewport (npm/CLI)

### 4. Draft or patch

1. Load `references/section-checklist.md` for required/optional sections by type.
2. Load only the matching template under `references/templates/` when creating a new README or doing a major restructure.
3. Prefer surgical edits when syncing; don’t rewrite a healthy README for style alone.
4. Load `references/writing-guide.md` when prose quality, AI-tone cleanup, or example hygiene needs a pass.
5. Load `references/quick-start-patterns.md` when the package is a public npm CLI/scaffolder, or the install section is hard to scan.

### 5. Validate before done

- [ ] Name + what/why + usage path present
- [ ] Install/run commands match lockfile / scripts / CI
- [ ] Quick Start leads with the interactive/happy path (flags under Non-interactive if needed)
- [ ] Examples are real or clearly marked as illustrative with verified APIs
- [ ] Links resolve; no invented features, deps, flags, or flag aliases
- [ ] Audience-appropriate sections only (checklist)
- [ ] Ask: anything else the reader needs that we missed?

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/section-checklist.md` | Choosing or auditing sections by project type |
| `references/evidence-discovery.md` | Large/monorepo trees, unclear entry points, sync audits |
| `references/writing-guide.md` | Prose cleanup, anti-patterns, example rules |
| `references/quick-start-patterns.md` | npm/CLI Quick Start density; Interactive vs Non-interactive shape |
| `references/templates/oss.md` | New or major OSS README |
| `references/templates/internal.md` | New or major internal/service README |
| `references/templates/personal.md` | Personal / portfolio project |
| `references/templates/config.md` | Dotfiles / config / “what’s in this folder” README |

`/update-readme` is a thin Cursor wrapper that invokes this skill in **update/sync** mode.
