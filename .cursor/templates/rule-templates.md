# Rule Templates

Copy the section you need into a new rule folder and customize:

```bash
mkdir -p .cursor/rules/<name>
# then create .cursor/rules/<name>/RULE.md
```

`/quick-start` can merge detected project info with these patterns.

---

## 1. Architecture

Copy to `.cursor/rules/architecture/RULE.md`.

```markdown
---
description: "Architecture boundaries and layering for this project"
alwaysApply: true
---

# Architecture

### Layer Structure (typical web app)

src/
├── components/     # UI (presentation)
├── services/       # Business logic
├── repositories/   # Data access
├── models/         # Domain types
├── utils/          # Shared utilities
└── config/         # Configuration

**Rules:** Components → services → repositories; no direct repo access from UI. Models shared. No circular dependencies.

### Module boundaries
- Clear public API per module; index exports; internals not exported.
- Loose coupling; interfaces at boundaries.

### Error handling
- Catch at boundaries (API, UI). Transform to domain errors. Log with context.

### State
- Single source of truth; immutable; changes via actions; derive, don't store duplicate state.

### Testing
- Unit (many) → integration (few) → E2E (critical paths). Test business logic and public interfaces; skip framework internals.

### API (REST)
- Nouns for resources; correct HTTP methods; version (e.g. `/v1/users`).

### Security
- Validate/sanitize input; parameterized queries; no secrets in code; use established auth libraries.
```

---

## 2. Coding Style

Copy to `.cursor/rules/coding-style/RULE.md`.

```markdown
---
description: "Naming, formatting, and function conventions"
globs: "**/*.{ts,tsx,js,jsx,py,go,rs}"
alwaysApply: false
---

# Coding Style

### Naming
- `camelCase` variables/functions; `PascalCase` classes/types; `SCREAMING_SNAKE_CASE` constants; `kebab-case` file names.

### Formatting
- 2-space indent (or project default); ~100 char line length; trailing commas; consistent semicolons. Group/sort imports; remove unused.

### Functions
- Under ~30 lines; single responsibility; early returns; document non-obvious params.

### Errors & comments
- Handle errors explicitly; custom domain error types; comment "why" not "what"; JSDoc for public APIs.

### Linters
- Align with project ESLint/Prettier/ruff/etc. in config files.
```

---

## 3. Project Commands

Copy to `.cursor/rules/project-cmds/RULE.md` (or update the existing one).

List the commands the agent should use: **build**, **test**, **run**, **lint**, **typecheck**. Include language-specific examples (npm/pip/cargo/go). Add env vars, Docker, DB, deploy if relevant. `/quick-start` detects from `package.json`/`Cargo.toml`/etc. and merges into `project/RULE.md` + `project-cmds/RULE.md`.

Example skeleton:

```bash
# Build: npm run build | cargo build | go build ./...
# Test:  npm test | pytest | cargo test | go test ./...
# Run:   npm run dev | python main.py | cargo run
# Lint:  npm run lint | ruff check | cargo clippy
```

Customize with your actual scripts and required env (e.g. `DATABASE_URL`, `API_KEY`).

---

## 4. Org / company policy

Copy to `.cursor/rules/org-<topic>/RULE.md` (use your own prefix — e.g. `org-security`, `acme-compliance`).

Org-named rule folders are **not** in the stock sync list, so `create-adsk update` / `sync-adsk.sh adopter` will not overwrite them. Full guide: [docs/customizing-org-rules.md](../../docs/customizing-org-rules.md).

```markdown
---
description: "Organization constraints agents must follow"
alwaysApply: true
---

# Org policy

## Must

- Follow verify commands in `@.cursor/rules/project-cmds` before claiming done
- Prefer specs (`/draft-spec`) for Medium+ behavior changes

## Must not

- Do not commit secrets, credentials, or private keys
- Do not bypass auth, authz, or supply-chain checks to ship faster

## Done when

- Relevant tests/lint/typecheck from `project-cmds` pass
- Review notes call out security- or compliance-sensitive diffs
```

Keep each org rule short (one concern). Put long playbooks in `.agents/skills/<company-skill>/` instead.
