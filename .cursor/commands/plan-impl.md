# /plan-impl

Create an implementation plan from a specification.

## Skill

Read and follow **`skills/spec-driven-workflow`**. Resolve paths with `references/artifact-homes.md`. For Cursor plan files, follow `references/cursor-adapter.md` (YAML `todos` required). When the **engineering-methods** pack is installed, use upstream `writing-plans` for granular task style — see `docs/engineering-methods.md`. Before planning Medium+, run or confirm the cross-requirement pass in `references/analyze-requirements.md`.

## Usage

```
/plan-impl path/to/spec.md
```

## Behavior

1. Read the spec; if open questions or unconfirmed assumptions remain, resolve those before planning.
2. **Analyze** (Medium+): cross-check REQs for conflicts, ambiguity, and gaps (`analyze-requirements.md`). Update the living spec if findings change REQs. If a plan already exists and REQs changed, treat this as a **resync** (replace stale todos).
3. Break work into ordered, verifiable tasks (files, tests, risks). Prefer tasks that map to `REQ-XXX` and stay within a focused file set. Prefer splitting **build** from **verify/review** so QA can run in parallel with the next slice. For bugfix specs, map tasks/tests to both FIX and KEEP (Unchanged) items.
4. **Tracer gate** (Large, and Medium when architecture/integration is ambiguous): include a thin vertical slice + one verify before multi-phase implement, or “N/A — architecture proven” with justification — see skill / `problem-size-guide.md`.
5. **Resolve the plan path** via the skill. As a Cursor `/` command, default to `.cursor/plans/{feature-name}.plan.md` unless the project already uses `docs/plans/` or the user overrides the path.
6. Write the plan with **trackable todos** (Cursor: non-empty frontmatter `todos`; never body-only REQ tables with empty Plan UI todos).
7. Suggest `/implement-spec` only after the user approves the plan (medium+).

Keep this command thin — planning depth lives in the skill / recommended upstream.
