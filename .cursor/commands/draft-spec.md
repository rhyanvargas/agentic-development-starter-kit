# /draft-spec

Generate a specification from a feature idea (or a surgical bugfix).

## Skill

Read and follow **`skills/spec-driven-workflow`** (especially `references/spec-writing-guide.md` and `references/artifact-homes.md`). For Cursor output homes, also follow `references/cursor-adapter.md`. For non-trivial bugs, follow `references/bugfix-workflow.md`.

## Usage

```
/draft-spec "your feature idea or description"
/draft-spec "Bug: …"   # use bugfix template when appropriate
```

## Behavior

1. If the idea is vague: surface assumptions and reframe into success criteria (2–3 questions max). Do not silently invent requirements.
2. Choose entry mode: **Requirements-First** (default), **Design-First** when TECH/NFRs dominate, or **Bugfix** (Current / Expected / Unchanged) for non-trivial defects.
3. Scan the codebase for related patterns.
4. Write a testable spec (prefer `REQ-XXX` IDs + acceptance criteria + test strategy). Include Assumptions / Open Questions when anything is unresolved.
5. **Resolve the spec path** via the skill (`artifact-homes.md`). As a Cursor `/` command, default to `.cursor/docs/specs/{feature-name}.md` unless the project already uses `docs/specs/` or the user passed `--out`.
6. Pause for user review on medium+ work; then suggest a cross-requirement **analyze** pass (`references/analyze-requirements.md`) before `/plan-impl`, or `/implement-spec` for small changes.

Do not duplicate the full playbook here — the skill is the source of truth.
