---
name: spec-driven-workflow
description: >-
  Draft specs, analyze requirements, plan implementation, implement from
  specs, review against specs (generator≠evaluator), extract specs from
  existing code, run surgical bugfix specs, multi-session handoff/progress,
  and size greenfield/brownfield work. Use when the user wants testable
  requirements, living specs, spec-driven development, session handoff,
  bugfix with regression fences, Design-First vs Requirements-First, or
  /draft-spec /plan-impl /implement-spec /review /extract-spec. Do not use
  for C4/solution architecture packets (use solution-architecture),
  DevOps/CI-CD strategy design, README authoring, Agent Skill optimization,
  AFK/Ralph automation products, or trivial one-line fixes.
---

# Spec-Driven Workflow

The spec is the shared source of truth for what to build and how to know it is done.

## Quick size guide

| Size | Workflow |
|------|----------|
| Trivial | Skip formal workflow; handle in chat |
| Small | Draft spec → implement |
| Medium | Draft spec → analyze → plan → implement → review |
| Large | Research first, then full workflow |

Read `references/problem-size-guide.md` when size is unclear.

## Gated procedure

Do not advance phases until the current artifact is good enough (user review for medium+; self-check for small).

```
SIZE → SPECIFY → ANALYZE (medium+) → PLAN (medium+) → CLEAR → IMPLEMENT → REVIEW
                    ↑______________ living spec + plan sync ______________|
```

1. **Size** — Match depth to problem size (table above).
2. **Specify** — Surface assumptions first, then write testable requirements (`REQ-XXX` preferred). Default **Requirements-First**. Read `references/spec-writing-guide.md`.
   - **Bugfix** (non-obvious / high-risk defects): use Current / Expected / **Unchanged** — read `references/bugfix-workflow.md`.
   - **Design-First** (strict NFRs, existing architecture, feasibility before scope): draft TECH/approach first, then derive REQs — see `references/spec-writing-guide.md`.
3. **Analyze** (medium+) — Cross-requirement check for conflicts, ambiguity, and gaps before planning. Read `references/analyze-requirements.md`.
4. **Plan** (medium+) — Break work into concrete, verifiable tasks. Prefer a written plan before multi-file changes.
   - **Architecture packet** (Large, and Medium when architecture/integration is ambiguous): require system context + container views (or “N/A — architecture proven”) and link ADRs for irreversible choices via `solution-architecture` / `/design-architecture` before multi-phase implement. See `references/problem-size-guide.md`.
   - **Tracer bullet** (Large, and Medium when architecture/integration is ambiguous): include a thin vertical slice + one verify **before** multi-phase implement, or an explicit “N/A — architecture proven” justification. See `references/problem-size-guide.md`.
   - Prefer splitting **build** tasks from **verify/review** tasks so QA can proceed in parallel with the next REQ slice (optional for Small).
5. **Clear** (Medium+) — Persist exploration into the living spec/plan; start implement lean. Do not carry the full exploration transcript as working context. Bounded explore (subagent or dedicated chat) is fine; durable findings must already be in artifacts. For multi-session work, read `references/session-handoff.md` (start checklist: living spec + plan + progress before coding).
6. **Implement** — Follow the spec/plan; map each requirement to tests unless non-behavioral with explicit justification. On Medium+ session end (or incomplete work), write the handoff/progress section per `session-handoff.md` — not an AFK product.
7. **Review** — Separate **evaluate** pass (generator ≠ evaluator): refute-minded check of spec compliance, regression fence, security-sensitive paths, tests, and docs/README drift on user-facing surface changes (hand off to `/update-readme` / `readme-authoring`; do not full-sync inside review unless asked). Do not treat implement-session self-grade as done. Read `references/review-evaluator.md`.
8. **Brownfield** — Document existing behavior with extract-spec before large changes. Read `references/brownfield-workflow.md`.

### Before writing a spec

**Surface assumptions immediately.** List what you are assuming and invite correction before drafting:

```
ASSUMPTIONS:
1. …
2. …
→ Correct me now or I'll proceed with these.
```

**Reframe vague goals as success criteria** (measurable / testable), then confirm:

```
REQUIREMENT: "Make the dashboard faster"
SUCCESS CRITERIA:
- LCP < 2.5s on 4G
- Initial data load < 500ms
→ Are these the right targets?
```

**Sketch test seams (medium+).** Prefer the highest useful *existing* boundary (API, module, port) over inventing new ones; confirm with the user before locking them into the spec. Details: `references/spec-writing-guide.md`.

Do not silently fill ambiguous requirements — that is the failure mode SDD exists to prevent.

### Living spec + plan sync

Update the spec when decisions or scope change; prefer updating the spec before implementing the change. Link PRs back to the spec section or `REQ-XXX` they satisfy.

**After material REQ/design edits:** re-run `/plan-impl` (or refresh Cursor Plan YAML `todos`) so tasks match the living spec. Do not implement against a stale plan.

## Artifact homes

Before writing a spec or plan, **resolve the output home** (do not assume `.cursor/`):

1. Explicit path from the user (`--out`, `@file`, concrete path)
2. Existing project convention (`docs/specs|plans` or `.cursor/docs/specs` / `.cursor/plans`)
3. Client default — Cursor `/` or Cursor wiring → `.cursor/...`; otherwise → `docs/specs` + `docs/plans`

Read `references/artifact-homes.md` whenever creating or locating specs/plans.  
Read `references/cursor-adapter.md` when the home is Cursor (Plan YAML `todos` required).

Slash commands are optional thin wrappers; details in `references/commands-reference.md`.

## Progressive disclosure

Load references only when needed:

| Reference | When to read |
|-----------|----------------|
| `references/artifact-homes.md` | Creating/locating specs or plans; path unclear |
| `references/cursor-adapter.md` | Cursor `/` commands or `.cursor/plans` / `.cursor/docs` homes |
| `references/session-handoff.md` | Medium+ multi-session start/end; progress + next REQ |
| `references/review-evaluator.md` | `/review` or Review phase; generator ≠ evaluator |
| `references/problem-size-guide.md` | Size unclear or contested |
| `references/spec-writing-guide.md` | Writing or reviewing a spec; Design-First vs Requirements-First |
| `references/analyze-requirements.md` | Medium+ before `/plan-impl`, or after material REQ edits |
| `references/bugfix-workflow.md` | Non-trivial bug fix; regression fence needed |
| `references/greenfield-workflow.md` | New feature, no existing behavior to preserve |
| `references/brownfield-workflow.md` | Changing or documenting existing code |
| `references/commands-reference.md` | Slash-command usage or options |
| `references/getting-started.md` | User asks how to install/setup ADSK |
| `references/spec-driven-overview.md` | User asks *why* SDD (not for routine runs) |
| `references/best-practices.md` | User asks for tips/external links |
| `references/extending.md` | Adding rules/commands/skills or pairing upstream packs |

## Quality gates

- Assumptions surfaced before drafting when requirements are ambiguous.
- Requirements are specific and testable.
- Medium+ specs get a cross-requirement analyze pass (or explicit “N/A — tiny REQ set already reviewed”) before plan.
- Medium+ specs name preferred test seams (highest useful existing boundary) when behavior is non-trivial.
- Bugfix specs (when used) document Unchanged behavior and tests cover the fence.
- After material living-spec edits, the plan/todos are resynced before implement.
- Large / ambiguous Medium plans include an architecture packet gate (or “N/A — architecture proven”) via `solution-architecture` when integration boundaries are unclear.
- Implemented requirements have automated tests (or a short justification when truly non-behavioral).
- **Fail-closed verify:** Before claiming done, run `project-cmds` (or documented project verify). If verify is **not** configured, do **not** claim done — instruct `/quick-start` or set `project-cmds` / portable equivalent. “Looks good” without verify is forbidden.
- **Multi-session handoff (Medium+):** Session start reads living spec + plan + progress; session end updates handoff (next REQ/T#, git expectation) per `session-handoff.md`. Not an AFK/Ralph product.
- **Generator ≠ evaluator (Medium+):** Do not claim done from implement self-grade alone; run a separate refute-minded `/review` per `review-evaluator.md` (bugfixes: Unchanged fence required).
