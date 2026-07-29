# /review

Post-implementation quality review — **generator ≠ evaluator**.

## Skill

Read and follow **`skills/spec-driven-workflow`** review guidance and **`references/review-evaluator.md`**. Apply `@.cursor/rules/testing` and `@.cursor/rules/project-cmds`. Resolve spec paths with `references/artifact-homes.md` when locating `--spec`.

## Usage

```
/review
/review path/to/file.ts
/review --spec path/to/spec.md
```

## Behavior

1. Adopt a **refute-minded evaluate** posture (separate from the implement session). Do not rubber-stamp implement self-grade as done.
2. Identify changed or specified files; prefer reviewing against the living `--spec` when provided.
3. Check at minimum: spec/REQ compliance, regression fence (bugfix Unchanged/KEEP), security-sensitive paths, test coverage vs REQs, fail-closed verify (or block “done”), and docs/README drift when user-facing surface changed (CLI, install, profiles/packs, Quick Start) — flag and hand off to `/update-readme` / `readme-authoring`; do not full-sync docs inside `/review` unless asked.
4. Report actionable findings by severity; offer to apply safe fixes when asked.
5. Re-run verify commands after fixes; re-review if changes were material.
