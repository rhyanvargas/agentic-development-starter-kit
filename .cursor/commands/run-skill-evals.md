# /run-skill-evals

Run with-skill vs without-skill output evals for a skill (Tier 2 style). Soft quality signal — not a merge gate.

## Skill / playbook

Follow **`skills/skill-optimizer`** → `references/eval-loop.md` (or `.agents/skills/skill-optimizer` in adopter apps). Full runbook: `docs/evaluating-skills.md`.

## Usage

```
/run-skill-evals
/run-skill-evals skills/spec-driven-workflow
/run-skill-evals .agents/skills/my-company-skill
```

## When to use

- You **changed** a skill’s behavior or description, or switched models
- You are shipping a **company** skill and need with/without evidence before commit

**Do not** re-benchmark every PR. For stock first-party skills, trust published numbers in `docs/evals/SCORECARD.md` unless the above applies.

## Behavior

1. Locate the target skill (ask if unclear). Prefer kit `skills/<name>` or adopter `.agents/skills/<name>`.
2. Confirm `evals/evals.json` exists (and ideally `evals/trigger/eval_queries.json`). If missing, stop and point to `/optimize-skill` first.
3. **Package cases** (pick one):
   - **This kit repo:** run `./scripts/run-skill-evals-soft.sh --skill <name>` → work under `.adsk-tier2-out/<name>/`.
   - **Adopter app (no kit scripts):** read prompts from `.agents/skills/<name>/evals/evals.json` directly; create a gitignored workspace (e.g. `.adsk-tier2-out/<name>/`) with `with_skill/` and `without_skill/` arms per case.
4. For **each** eval case, in a **clean** context:
   - **with_skill** — skill available; paste the prompt; save output
   - **without_skill** — same prompt without the skill (or prior version); save output
5. Grade each assertion PASS/FAIL with evidence into `grading.json` (or equivalent). Prefer mechanical checks when possible.
6. Summarize pass-rate Δ (and token/time Δ if available). For kit first-party skills, offer a SCORECARD paste row; for company skills, report in-chat / PR notes (do not invent kit SCORECARD edits unless asked).
7. **Required close-out:** load `skill-optimizer` → `references/eval-loop.md` → **After grading — recommended next actions**. Append a **Recommended next actions** section (Do now / Do next / Skip) mapped from the decision table — fix `with_skill` FAILs first, then SCORECARD/PR notes, then assertion tighten. Offer to execute the top action when it is a small obvious edit. Do not end on scores alone.
8. Reminder: Tier 1 (`./scripts/check-skills-ci.sh` in the kit) only checks harness shape — it does not replace this loop.
