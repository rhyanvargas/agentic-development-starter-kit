---
name: spec-driven-workflow
description: >-
  Draft specs, plan implementation, implement from specs, review against
  specs, extract specs from existing code, and size greenfield/brownfield
  work. Use when the user wants testable requirements, living specs,
  spec-driven development, or /draft-spec /plan-impl /implement-spec
  /review /extract-spec. Do not use for C4/solution architecture packets
  (use solution-architecture), DevOps/CI-CD strategy design, README
  authoring, Agent Skill optimization, or trivial one-line fixes.
---

# Spec-Driven Workflow

The spec is the shared source of truth for what to build and how to know it is done.

## Quick size guide

| Size | Workflow |
|------|----------|
| Trivial | Skip formal workflow; handle in chat |
| Small | Draft spec → implement |
| Medium | Draft spec → plan → implement → review |
| Large | Research first, then full workflow |

Read `references/problem-size-guide.md` when size is unclear.

## Gated procedure

Do not advance phases until the current artifact is good enough (user review for medium+; self-check for small).

```
SIZE → SPECIFY → PLAN (medium+) → CLEAR → IMPLEMENT → REVIEW
              ↑______________ living spec ______________|
```

1. **Size** — Match depth to problem size (table above).
2. **Specify** — Surface assumptions first, then write testable requirements (`REQ-XXX` preferred). Read `references/spec-writing-guide.md`.
3. **Plan** (medium+) — Break work into concrete, verifiable tasks. Prefer a written plan before multi-file changes.
   - **Architecture packet** (Large, and Medium when architecture/integration is ambiguous): require system context + container views (or “N/A — architecture proven”) and link ADRs for irreversible choices via `solution-architecture` / `/design-architecture` before multi-phase implement. See `references/problem-size-guide.md`.
   - **Tracer bullet** (Large, and Medium when architecture/integration is ambiguous): include a thin vertical slice + one verify **before** multi-phase implement, or an explicit “N/A — architecture proven” justification. See `references/problem-size-guide.md`.
   - Prefer splitting **build** tasks from **verify/review** tasks so QA can proceed in parallel with the next REQ slice (optional for Small).
4. **Clear** (Medium+) — Persist exploration into the living spec/plan; start implement lean. Do not carry the full exploration transcript as working context. Bounded explore (subagent or dedicated chat) is fine; durable findings must already be in artifacts.
5. **Implement** — Follow the spec/plan; map each requirement to tests unless non-behavioral with explicit justification.
6. **Review** — Check correctness, security-sensitive paths, test coverage, and spec compliance.
7. **Brownfield** — Document existing behavior with extract-spec before large changes. Read `references/brownfield-workflow.md`.

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

### Living spec

Update the spec when decisions or scope change; prefer updating the spec before implementing the change. Link PRs back to the spec section or `REQ-XXX` they satisfy.

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
| `references/problem-size-guide.md` | Size unclear or contested |
| `references/spec-writing-guide.md` | Writing or reviewing a spec |
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
- Medium+ specs name preferred test seams (highest useful existing boundary) when behavior is non-trivial.
- Implemented requirements have automated tests (or a short justification when truly non-behavioral).
- **Fail-closed verify:** Before claiming done, run `project-cmds` (or documented project verify). If verify is **not** configured, do **not** claim done — instruct `/quick-start` or set `project-cmds` / portable equivalent. “Looks good” without verify is forbidden.
