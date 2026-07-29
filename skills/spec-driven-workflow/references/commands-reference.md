# Commands Reference

Complete reference for all spec-driven workflow commands.

**Paths:** Resolve spec/plan locations with `artifact-homes.md` before writing files. Cursor `/` commands default to `.cursor/...` unless the project already uses `docs/specs|plans` or the user passes an explicit path. Cursor Plan YAML `todos` rules: `cursor-adapter.md`.

## Command Summary

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/draft-spec` | Generate feature or bugfix spec | Starting a new feature or non-trivial bug |
| `/plan-impl` | Create / **resync** implementation plan | Before coding medium+ changes; after living-spec REQ edits |
| `/implement-spec` | Generate code from spec | After spec (and plan, if any) is approved |
| `/review` | Quality check | After implementation |
| `/extract-spec` | Document existing code | Brownfield projects |
| `/quick-start` | Initialize workflow | First-time setup |
| `/design-architecture` | Sized C4 architecture packet + ADRs | Large / ambiguous Medium architecture |
| `/design-devops-strategy` | Design CI/CD + branching strategy | Delivery / platform decisions |
| `/optimize-skill` | Optimize a skill for triggers/tokens | Creating or editing skills |
| `/update-readme` | Sync README with codebase | Keep README accurate |

---

## /draft-spec

Generate a specification document from a feature idea.

### Usage
```
/draft-spec "your feature description"
```

### Examples
```
/draft-spec "Add user authentication with email/password"
/draft-spec "Create a dashboard showing sales metrics"
/draft-spec "Refactor payment service to use Stripe"
```

### Behavior
1. Asks clarifying questions if needed; chooses Requirements-First (default), Design-First, or Bugfix when appropriate
2. Searches codebase for context
3. Resolves output home (`artifact-homes.md`); Cursor default `.cursor/docs/specs/{feature-name}.md`
4. On medium+, suggests analyze (`analyze-requirements.md`) before `/plan-impl`

### Output
- Spec file with requirements, constraints, acceptance criteria
- Location: resolved spec home (Cursor default `.cursor/docs/specs/`)

### Options
- Add context: `/draft-spec "feature" @src/related-file.ts`
- Specify output: `/draft-spec "feature" --out docs/specs/custom-name.md`

---

## /plan-impl

Create an implementation plan from a specification.

### Usage
```
/plan-impl path/to/spec.md
```

### Examples
```
/plan-impl .cursor/docs/specs/user-auth.md
/plan-impl @docs/specs/payment-refactor.md
```

### Behavior
1. Reads the spec; runs Medium+ cross-requirement analyze (or confirms N/A)
2. Breaks down into concrete steps (prefer build vs verify/review split for parallel QA); **resyncs** todos when REQs changed since last plan
3. Identifies files to create/modify; for bugfix specs, maps FIX + KEEP items
4. Plans tests and verification; for Large (and ambiguous Medium), requires a **tracer bullet** task or “N/A — architecture proven” justification
5. Writes **trackable todos** (Cursor: YAML frontmatter `todos` — see `cursor-adapter.md`)

### Output
- Plan file with steps, files, tests, risks, and trackable todos
- Location: resolved plan home (Cursor default `.cursor/plans/{feature-name}.plan.md`)

### When to Use
- Medium and large changes
- Multi-file modifications
- Complex refactors

### When to Skip
- Small, single-file changes
- Clear, obvious implementations

---

## /implement-spec

Generate code from a specification or plan.

### Usage
From spec:
```
/implement-spec path/to/feature.md
```

From plan:
```
/implement-spec path/to/feature.plan.md
```

### Behavior
1. Clears exploration into living artifacts when Medium+ (start lean); reads living spec + plan + **Handoff / Progress** before coding (`session-handoff.md`)
2. Reads spec/plan
3. Creates and modifies files
4. Writes tests
5. **Fail-closed:** runs project verify (`project-cmds`); fixes failures. If verify is not configured, refuses to claim done and points to `/quick-start` — never a silent “looks good”
6. Fixes issues (up to 3 iterations)
7. On Medium+ session end with incomplete work: updates **Handoff / Progress** (done, files touched, next REQ/T#, git expectation)
8. Suggests `/review` — implement self-check is not the evaluate pass (`review-evaluator.md`)

### Output
- Generated code following the spec
- Tests for new functionality
- Updated files (and handoff section when applicable)

### Options
- Dry run: `/implement-spec spec.md --dry-run` (shows what would change)
- No tests (discouraged): `/implement-spec spec.md --no-tests`
  - Only for clearly non-behavioral work (docs/formatting) or repos without a test harness
  - Must include an explicit “no tests needed because…” justification in the plan/spec

---

## /review

Perform a **separate evaluate** pass on code changes (generator ≠ evaluator). Prefer a fresh `/review` after implement — do not treat implement-session self-grade as done. Depth: `review-evaluator.md`.

### Usage
Review recent changes:
```
/review
```

Review specific files:
```
/review src/services/UserService.ts
```

Review against spec:
```
/review --spec .cursor/docs/specs/feature.md
```

### Behavior
1. Refute-minded evaluate posture (separate from implement)
2. Identifies files to review
3. Checks spec/REQ compliance, Unchanged/KEEP fence (bugfix), security-sensitive paths, tests vs REQs
4. Confirms fail-closed verify already ran (or blocks “done”)
5. Reports issues and suggestions; re-verify after fixes

### Output
- Review summary with issues by severity
- Spec compliance checklist (if --spec)
- Suggested fixes

### Review Checklist
- Spec / REQ compliance (refute “done”)
- Bugfix Unchanged / KEEP regression fence (fail review if skipped)
- Security-sensitive paths (auth, secrets, money, PII, destructive ops)
- Testing (coverage vs REQs, edge cases)
- Fail-closed verify evidence
- Code quality / standards (naming, complexity, patterns) as secondary

---

## /extract-spec

Reverse-engineer documentation from existing code.

### Usage
From path:
```
/extract-spec src/services/
```

From concept:
```
/extract-spec "authentication flow"
```

From file:
```
/extract-spec src/api/users.ts
```

### Behavior
1. Searches for relevant code
2. Analyzes behavior and interfaces
3. Generates documentation spec

### Output
- Spec file documenting existing behavior
- Location: resolved spec home (Cursor default `.cursor/docs/specs/{module}-current.md`)

### Use Cases
- Brownfield onboarding
- Filling documentation gaps
- Understanding legacy code
- Preparing for refactors

---

## /quick-start

Initialize the spec-driven workflow for a project.

### Usage
```
/quick-start
```

### Behavior
1. Detects tech stack (language, framework, tools)
2. Reads existing config files
3. Updates `.cursor/rules/project/RULE.md` and `.cursor/rules/project-cmds/RULE.md`
4. Confirms skills under `.agents/skills/`
5. Ends with the **where truth lives** checklist: artifact home, verify location, skills path, next command (`/draft-spec` vs `/extract-spec`)

### Output
- Updated project rules
- Detected stack summary
- Recommended workflow (greenfield vs brownfield)
- Checklist of where specs, verify, and skills live

### What It Detects
- Package manager (npm, pip, cargo, etc.)
- Framework (React, Django, Rails, etc.)
- Test framework (Jest, pytest, etc.)
- Linter (ESLint, ruff, etc.)
- Build commands
- Artifact home convention (`.cursor/...` vs `docs/...`)

---

## Combining Commands

### Greenfield Flow
```
/quick-start                                    # Setup
/draft-spec "new feature"                       # Spec
/plan-impl .cursor/docs/specs/feature.md        # Plan
/implement-spec .cursor/docs/specs/feature.md   # Build
/review --spec .cursor/docs/specs/feature.md    # Verify
```

### Brownfield Flow
```
/quick-start                                    # Setup
/extract-spec src/legacy/                       # Document
/draft-spec "change to legacy"                  # Spec change
/plan-impl .cursor/docs/specs/change.md         # Plan
/implement-spec .cursor/docs/specs/change.md    # Build
/review --spec .cursor/docs/specs/change.md     # Verify
```

### Quick Fix (Skip workflow)
```
"Fix the typo in README.md"            # Direct chat
```

---

## /design-architecture

Collaborate on a sized solution-architecture packet (brief, C4 views, ADRs, risks).

### Usage
```
/design-architecture
/design-architecture "Notifications service — Medium, unclear webhook integration"
```

### Behavior
1. Sizes rigor (Small skip / Medium packet / Large / AI extensions)
2. Drafts brief + required C4 views (logical first)
3. Records ADRs and a lite risk register; links from the living spec/plan

### Skill
`skills/solution-architecture`

---

## /design-devops-strategy

Collaborate on a concise DevOps strategy (branching, CI/CD, environments, governance).

### Usage
```
/design-devops-strategy
/design-devops-strategy "GitHub Actions + Kubernetes, dev/stage/prod"
```

### Behavior
1. Asks up to 5–10 targeted questions
2. Drafts a short strategy using `skills/devops-strategy-facilitator/references/strategy-template.md`
3. Records a decision log and open questions

### Skill
`skills/devops-strategy-facilitator`

---

## /update-readme

Synchronize README.md with current codebase state.

Invokes first-party **`readme-authoring`** in update/sync mode (see `.agents/skills/readme-authoring`).

### Usage
```
/update-readme
/update-readme --section tech-stack
```

### Behavior
1. Gather evidence (manifests, entry points, examples, existing docs)
2. List missing / stale findings vs README claims
3. Patch sections to match; prefer links over duplicated content
4. Verify install/run commands and tech stack against actual files — do not invent

### When to Use
- After adding/removing dependencies or modules
- When README and code have drifted
- Before releasing or onboarding

---

## Troubleshooting

### Command not found
- Verify `.cursor/commands/` folder exists
- Check command files are present
- Restart Cursor IDE

### Spec not generated
- Provide more detail in description
- Confirm resolved spec home exists (or allow the agent to create it) — see `artifact-homes.md`
- Review agent output for errors

### Plan shows 0 To-dos in Cursor
- Ensure `.cursor/plans/*.plan.md` has YAML frontmatter with a non-empty `todos` array (`cursor-adapter.md`)
- A REQ→task table in the body alone is not enough for Cursor Plan UI

### Plan missing files
- Spec may be too vague
- Add more context to spec
- Reference related files with @

### Implementation fails
- Check tests for clues
- Refine spec with clarifications
- Run `/review` to identify issues
