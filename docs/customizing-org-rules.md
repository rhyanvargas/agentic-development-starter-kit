# Customize org rules and policies (adopters)

For team leads who adopted ADSK and need **agent-readable** organization policies that survive kit updates.

**Companion:** [for-eng-leads.md](product/for-eng-leads.md) (mandate vs leave open) · [using-adsk.md](using-adsk.md) (install / update) · [skill-authoring.md](skill-authoring.md) (company skills)

---

## Short answers

| Question | Answer |
|----------|--------|
| Where do I put org policy? | Your **app repo**: `.cursor/rules/<name>/RULE.md`, short `AGENTS.md`, and optional `.agents/skills/<company-skill>/` |
| Will `create-adsk update` wipe my rules? | **No** for org-named rule folders. Stock rule dirs are **kept if present** unless you pass `--force-rules` |
| How do agents actually respect them? | Keep rules **short, concrete, and always-on (or glob-scoped)**; put long playbooks in skills |

ADSK gives the **mechanism** (rules + skills + update that preserves custom dirs). Your lead writes the **policy text** and commits it so the team shares one floor.

---

## 1. What to customize (and what not to)

Prefer the kit split (also in [skill-authoring.md](skill-authoring.md)):

| Artifact | Put here | Example |
|----------|----------|---------|
| **Rules** / `AGENTS.md` | Stable constraints and quality gates | “Never commit secrets”; “PRs need `/review` against a spec”; verify commands |
| **Skills** | Multi-step playbooks | Company security review, naming migration, release checklist |
| **Commands** | Thin `/` wrappers that **point at** skills/rules | Do **not** bury org policy only in commands — updates **rewrite** stock commands |

Do **not** fork the upstream kit repo to hold company policy. Keep policy in the **adopter app** (or a company app template) and version it in git.

### Recommended layout in your app

```text
your-app/
├── AGENTS.md                          # optional short always-on constraints
├── .adsk/config.json                  # create-adsk profile pin
├── .cursor/
│   └── rules/
│       ├── testing/                   # stock (add-if-missing; edit carefully)
│       ├── project-cmds/              # fill with YOUR verify commands
│       ├── skill-authoring/           # stock when maintainer profile
│       ├── org-security/RULE.md       # yours — never touched by stock sync
│       └── org-coding-standards/RULE.md
└── .agents/skills/
    └── my-company-review/             # optional playbook skill
        └── SKILL.md
```

Name org rules with a clear prefix (`org-`, `company-`, team name). Stock sync only considers the stock set: `skill-authoring`, `testing`, `project-cmds` ([`packages/create-adsk/src/cursor-sync.ts`](../packages/create-adsk/src/cursor-sync.ts), [`scripts/sync-adsk.sh`](../scripts/sync-adsk.sh)).

---

## 2. Add org rules (happy path)

1. Adopt ADSK (`npx create-adsk`) so Cursor wiring exists (profiles other than `skills-only`).
2. Create a rule folder and `RULE.md`:

   ```bash
   mkdir -p .cursor/rules/org-security
   ```

3. Start from [`.cursor/templates/rule-templates.md`](../.cursor/templates/rule-templates.md) (architecture, coding style, project-cmds) or the skeleton below.
4. Commit the folder. That is how the team gets the policy — same as shared lint config.
5. Restart / refresh the agent (or open a new chat) so rules are picked up.

### Minimal `RULE.md` skeleton

ADSK uses **folders + `RULE.md`** (not loose `.mdc` files):

```markdown
---
description: "Org security constraints agents must follow"
alwaysApply: true
---

# Org security

## Must

- Never commit secrets, API keys, or `.env` contents
- Auth and PII changes require tests and an explicit review note

## Must not

- Do not weaken auth checks to “make the feature work”
- Do not add dependencies without supply-chain review (see `@.cursor/rules/project-cmds` / Socket)

## Done when

- Verify commands in `@.cursor/rules/project-cmds` pass
```

### Scope: always-on vs file-specific

| Frontmatter | When |
|-------------|------|
| `alwaysApply: true` | Org floor every session (security, DoD, compliance) |
| `globs: "**/*.{ts,tsx}"` + `alwaysApply: false` | Language or path conventions only when those files are in play |

Prefer **several small rules** (one concern each) over one giant policy dump.

### Fill `project-cmds` early

Agents need real verify commands. Run `/quick-start` or edit `.cursor/rules/project-cmds/RULE.md` with your build/test/lint/typecheck. Without this, policy that says “must verify” has nothing executable to obey.

---

## 3. Survive kit updates (do not get overridden)

| Update path | What happens to **your** rules |
|-------------|--------------------------------|
| `npx create-adsk update` | Writes/refreshes **commands**; stock rules **add-if-missing**; **skips** existing stock dirs unless `--force-rules` |
| `sync-adsk.sh adopter` | Same rule behavior (`--force-rules` to overwrite stock dirs) |
| `npx skills update` | Skills only — **does not** touch `.cursor/rules/` |

**Guarantees (by design):**

- Rule directories **you created** (`org-*`, etc.) are **never** part of the stock sync list → not overwritten or deleted by update.
- Specs/plans under `.cursor/docs/specs/` and `.cursor/plans/` are **never** overwritten.
- Existing stock rule dirs are **kept** on update so your edits to `project-cmds` / `testing` survive.

**Avoid losing customizations:**

| Do | Don’t |
|----|--------|
| Put org policy in **new** rule folders (`org-…`) | Rely on editing stock rule text *and* routinely running `--force-rules` |
| Commit `.cursor/rules/org-*/` | Assume uncommitted local rules are the team standard |
| Use `--force-rules` only when you **intend** to reset stock rules from the kit | Put the only copy of org policy inside a stock command `.md` (commands refresh on update) |

Check after update: `npx create-adsk status`, and confirm your `org-*` folders are still present.

---

## 4. Write rules agents will respect

Agents follow **short, actionable constraints** better than long essay policy. Align with Cursor rule practice and ADSK lean steering:

1. **One concern per rule** — security ≠ style ≠ release.
2. **Keep it short** — aim under ~50 lines of body; link internal docs for depth instead of pasting them.
3. **Must / must-not / done-when** — imperative language; avoid vague “be careful with…”.
4. **Concrete examples** — show bad vs good when the mistake is common (copy patterns from [rule-templates](../.cursor/templates/rule-templates.md)).
5. **Point at verify** — reference `@.cursor/rules/project-cmds` so “done” is fail-closed.
6. **Don’t duplicate playbooks** — if the procedure is multi-step, write a **company skill** ([using-adsk.md §4](using-adsk.md#4-add-your-own-skill-your-project-only)) and keep the rule as a trigger + constraints.
7. **Company skills** — profile ≥ `maintainer`, then `/optimize-skill` and evals before you treat them as team standard ([evaluating-skills.md](evaluating-skills.md)).

### Rules vs company skills

| Use a **rule** when… | Use a **skill** when… |
|----------------------|------------------------|
| Constraint applies often and is short | Steps, checklists, or references are long |
| Always-on or simple globs | Agent should load depth only when the topic comes up |
| Quality gate (“must run tests”) | Facilitation (“run our threat-model interview”) |

### Quick checklist before you commit a rule

- [ ] Folder `.cursor/rules/<name>/RULE.md` with `description` + `alwaysApply` and/or `globs`
- [ ] One concern; body stays skim-friendly
- [ ] Must / must-not (or equivalent) are testable in review
- [ ] Org name prefix so it won’t collide with future stock rules
- [ ] Committed in the app (or company template), not only on one laptop
- [ ] After a dry-run update, rule folder still present

---

## 5. Team distribution

| Approach | When |
|----------|------|
| Commit rules/skills in each app | Default — profile + org overlay travel with the repo |
| Company app template / cookiecutter | New repos inherit the same `org-*` rules |
| Mandate in eng policy | Profile ≥ `core`/`delivery` + required `org-*` folders — see [for-eng-leads.md](product/for-eng-leads.md) |

Individuals can still add personal skills via `npx skills` without changing the shared floor.

---

## Related

| Doc | Use |
|-----|-----|
| [using-adsk.md](using-adsk.md) | Install, update, company skills |
| [for-eng-leads.md](product/for-eng-leads.md) | Profile × pack mandate; shared floor vs personal ceiling |
| [agent-autonomy.md](product/agent-autonomy.md) | HITL vs AFK norms |
| [skill-authoring.md](skill-authoring.md) | Lean steering; company skill layout |
| [`.cursor/templates/rule-templates.md`](../.cursor/templates/rule-templates.md) | Copy-paste rule starters |
