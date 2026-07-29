# /implement-spec

Implement from a specification or plan.

## Skill

Read and follow **`skills/spec-driven-workflow`**. Honor `@.cursor/rules/testing` and `@.cursor/rules/project-cmds` for tests and verify commands. When the **engineering-methods** pack is installed, follow `test-driven-development` (and `systematic-debugging` on failures) — see `docs/engineering-methods.md`.

## Usage

```
/implement-spec path/to/spec-or-plan.md
```

## Behavior

1. **Clear** (Medium+): confirm exploration is persisted in the living spec/plan; start this session lean — see skill gated procedure. **Handoff:** read living spec + plan + latest progress before coding (`references/session-handoff.md`). If the living spec changed after the plan was written, **resync** (`/plan-impl`) before coding.
2. Read the spec or plan; follow the plan step-by-step when present. For bugfix specs, honor the Unchanged (KEEP) fence.
3. Implement with tests mapped to requirements (or justify non-behavioral exceptions).
4. Update plan todo status as steps complete (Cursor Plan YAML `todos` and/or portable checklist — see `references/cursor-adapter.md` / `artifact-homes.md`).
5. **Fail-closed verify:** run `project-cmds` / project verify; fix failures before claiming done. If verify is missing, refuse “done” and point to `/quick-start` — do not invent a silent pass.
6. **Session end (Medium+ incomplete):** update the plan/spec **Handoff / Progress** section (done / files touched / next REQ or T# / git expectation) per `session-handoff.md`.
7. Suggest `/review` when implementation is complete — do not treat this session’s self-check as the evaluate pass (`references/review-evaluator.md`).
