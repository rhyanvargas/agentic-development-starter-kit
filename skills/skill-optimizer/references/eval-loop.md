# Eval loop (trigger + output)

Use when adding or revising skill evals, or finishing a `/run-skill-evals` pass. Repo overview: `docs/evaluating-skills.md`.

## Trigger accuracy

1. Build ~20 labeled queries (`evals/trigger/eval_queries.json`).
2. Split train vs validation (do not tune on validation).
3. For train failures:
   - Missed should-trigger → broaden intent categories (not single keywords)
   - False should-not → add boundaries / narrow scope
4. Repeat a few iterations; select by **validation** pass rate.
5. Sanity-check with 5–10 fresh queries never used in tuning.

Optional automation: Anthropic [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) (see `recommended-skills.json`).

## Output quality

For each case in `evals/evals.json`, run clean contexts (or invoke `/run-skill-evals`):

1. **with_skill** — skill available
2. **without_skill** (or prior version)

Record assertion PASS/FAIL with evidence; capture `total_tokens` / `duration_ms` when available.

Patterns:

- Always pass both ways → assertion has no signal; remove
- Always fail both → fix case/assertion
- Pass only with skill → keep; note which instruction helped
- High variance → tighten ambiguous instructions
- Large token Δ with small quality gain → cut activation-tier content

## Stop criteria

- Trigger validation acceptable on near-misses
- Output pass-rate improved or plateaued with acceptable token cost
- `skills-ref validate` still green
- Human feedback empty or only nits

## After grading — recommended next actions (required)

When a with/without (Tier 2) pass finishes, **end the user-facing response** with a
**Recommended next actions** section. Do not stop at pass-rate tables alone — map
results to concrete steps the user can take without asking “what next?”.

### Decision table (use evidence from grading)

| Signal | Recommended action |
|--------|--------------------|
| **with_skill FAIL** on any assertion | Priority: edit that skill’s instructions/refs so the miss cannot recur; cite eval id + assertion. Then re-run only that skill (`/run-skill-evals skills/<name>`). |
| **with_skill perfect**, **Δ ≥ ~0.10** | Keep skill; publish/update SCORECARD (kit) or PR notes (company skill). No rewrite unless user wants polish. |
| **with_skill perfect**, **Δ ≈ 0** (both arms strong) | Assertions may lack signal — tighten or replace weak checks; do **not** bloat SKILL.md chasing a larger Δ. |
| **Always PASS both arms** for an assertion | Remove or rewrite that assertion (no discriminatory power). |
| **Always FAIL both arms** | Fix the case/assertion (or a shared missing capability) before more skill prose. |
| **Large token/time Δ, small quality Δ** | Cut activation-tier text; move depth to `references/` with when-to-load. |
| **Kit first-party scores changed** | Update `docs/evals/SCORECARD.md` aggregate row + Eval readiness note (ask before commit if commit wasn’t requested). |
| **Company / adopter skill** | Report keep/revise in-chat or PR notes — do not invent kit SCORECARD rows. |
| **Harness missing** (`evals.json` / triggers) | Stop scoring; send user to `/optimize-skill` first. |
| **Plateau + only nits** | Stop iterating; ship. |

### Response shape (append after the score summary)

```markdown
## Recommended next actions

1. **Do now** — … (highest-impact with_skill FAILs or SCORECARD paste)
2. **Do next** — … (assertion tighten / single-skill re-run)
3. **Skip / defer** — … (force re-run all arms, full rewrite, etc.)
```

Order actions by impact: fix **with_skill** misses → publish scores → tighten no-signal assertions → optional polish. Offer to execute the top action in the same turn when it is a small, obvious edit.
