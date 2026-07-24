# Evaluating skills (ADSK)

How to test whether a skill produces good outputs using **eval-driven iteration**. Based on [Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills).

## Adopters first

| Goal | Action |
|------|--------|
| Decide keep / optional / replace for **kit** skills | Read [evals/SCORECARD.md](evals/SCORECARD.md) — do **not** re-run every PR |
| Ship or change a **company** skill | `/optimize-skill` then `/run-skill-evals` (see [using-adsk.md](using-adsk.md#5-evaluating-skills-adopters)) |
| Re-benchmark after a model change | `/run-skill-evals` for the affected skill only |

Evals are a maintainer quality loop. Cursor entrypoint: **`/run-skill-evals`**. Hard LLM CI gates and `create-adsk eval` are deferred (see Tier 3 below).

## Why evals

A single happy-path prompt is not enough. Evals answer:

- Does the skill beat **no skill** (or the previous version)?
- Does it hold across varied phrasing and edge cases?
- What does it cost in time/tokens?

## Test cases (`evals/evals.json`)

Each case has:

- **prompt** — realistic user message
- **expected_output** — human description of success
- **files** (optional) — fixtures under `evals/files/`
- **assertions** (add after first run) — verifiable pass/fail checks

Start with **2–3** cases plus at least one **edge** case. Vary phrasing and formality.

Example shape (see first-party skills for live files):

```json
{
  "skill_name": "example",
  "evals": [
    {
      "id": 1,
      "prompt": "…",
      "expected_output": "…",
      "assertions": ["…"]
    }
  ]
}
```

## Running evals

For each case, run **twice** in a clean context:

1. **with_skill** — agent has the skill path
2. **without_skill** (or prior version snapshot)

Workspace layout (generated; gitignored):

```
<skill>-workspace/
└── iteration-1/
    ├── eval-<name>/
    │   ├── with_skill/{outputs,timing.json,grading.json}
    │   └── without_skill/{outputs,timing.json,grading.json}
    └── benchmark.json
```

Record `total_tokens` and `duration_ms` in `timing.json` when available.

## Grading

Grade each assertion **PASS/FAIL with evidence** (quote paths or output). Prefer scripts for mechanical checks (file exists, valid JSON). Use LLM grading for semantic checks; use **blind A/B** when comparing versions.

## Aggregating

Compute pass-rate (and optional time/token) deltas into `benchmark.json`. Patterns to watch:

- Assertions that always pass both ways → remove (no signal)
- Always fail both ways → fix assertion or case
- Pass only with skill → keep; understand which instruction caused it
- High variance → tighten ambiguous instructions

## Recommended next actions (after every Tier 2 pass)

Do **not** end on a score table alone. Map grading evidence to concrete steps (full decision table: `skill-optimizer` → `references/eval-loop.md`):

1. **Do now** — fix any `with_skill` FAILs (skill instructions/refs), or paste SCORECARD/PR notes when scores changed
2. **Do next** — tighten no-signal assertions; re-run only the affected skill
3. **Skip / defer** — full force re-run of all arms, broad rewrites, or further iteration when deltas have plateaued

Cursor `/run-skill-evals` must append this section automatically.

## Trigger evals

Separate from output quality. Store labeled queries under `evals/trigger/eval_queries.json`:

```json
[
  { "query": "…", "should_trigger": true },
  { "query": "…", "should_trigger": false }
]
```

Aim for ~20 queries (half should / half should not). Prefer near-miss negatives. See [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions).

When authoring or revising skills, follow **`skill-optimizer`** (`references/eval-loop.md` inside that skill) so trigger + output loops stay coupled to token budgets.

## Iteration loop

1. Grade + human feedback + skim transcripts  
2. Propose lean, generalized skill edits (explain *why*)  
3. Rerun in `iteration-N+1/`  
4. Stop when feedback is empty or deltas plateau  

Optional automation: Anthropic [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) (listed in `recommended-skills.json`).

## CI tiers (this kit)

| Tier | When | What | Merge impact |
|------|------|------|--------------|
| **1 (hard)** | Every PR + every push to `main` (`.github/workflows/skills-ci.yml`) | `skills-ref validate` + eval harness integrity (`evals.json` + trigger queries shape) via [`scripts/check-skills-ci.sh`](../scripts/check-skills-ci.sh) | Fails the job on check failure; required check context `tier1` |
| **2 (soft)** | Weekly schedule + `workflow_dispatch` (`.github/workflows/skills-evals-soft.yml`) | Packages all first-party skills (or one via input): prompts + grading stubs + SCORECARD paste via [`scripts/run-skill-evals-soft.sh`](../scripts/run-skill-evals-soft.sh); uploads artifact. Agent loops stay maintainer-run (no LLM in Actions yet) | Must **not** be a required PR check; does not block release-please |
| **3** | Future | Hard pass-rate gate vs baselines | Out of scope until flakiness/cost baselines exist |

Local verify (same as CI Tier 1):

```bash
./scripts/check-skills-ci.sh
./scripts/check-skills-ci.sh --self-test
```

Tier 2 package (soft; default all first-party skills):

```bash
./scripts/run-skill-evals-soft.sh
./scripts/run-skill-evals-soft.sh --all
./scripts/run-skill-evals-soft.sh --skill readme-authoring
./scripts/run-skill-evals-soft.sh --self-test
```

Tier 1 has **no path filters** so the required `tier1` status always reports (including release-please PRs that only touch changelog/version).

### Tier 2 runbook

**Goal:** fill numeric with/without rows in [evals/SCORECARD.md](evals/SCORECARD.md). Tier 1 never produces those numbers.

**Cursor:** `/run-skill-evals` (or `/run-skill-evals <skill-path>`) drives the same loop for kit or adopter skills.

1. **Package** (local or Actions):
   ```bash
   ./scripts/run-skill-evals-soft.sh
   # → .adsk-tier2-out/{tier2-batch-summary.md,scorecard-paste-all.md,<skill>/...}
   ./scripts/run-skill-evals-soft.sh --skill skill-optimizer
   # → .adsk-tier2-out/skill-optimizer/{tier2-summary.md,scorecard-paste.md,cases.json,eval-*/}
   ```
   Or: Actions → **skills-evals-soft** → Run workflow → optional `skill` input (`all` or one skill) → download artifact.  
   Adopter apps without kit scripts: read prompts from `.agents/skills/<name>/evals/evals.json` (see `/run-skill-evals`).
2. **Run agents** for each `eval-<id>/`: clean context **with** skill, then **without**; paste prompts from `cases.json`; save outputs under each arm.
3. **Grade** each `grading.json` (PASS/FAIL + evidence). Prefer scripts for mechanical checks; LLM/blind A/B for semantic ones ([Grading](#grading)).
4. **Paste** the aggregate table from `scorecard-paste.md` into [evals/SCORECARD.md](evals/SCORECARD.md). Update that skill’s **Eval readiness** note when benchmarked.
5. **Recommend next actions** — required close-out ([above](#recommended-next-actions-after-every-tier-2-pass)); prioritize `with_skill` misses over chasing larger Δ.
6. Keep workspaces gitignored (`.adsk-tier2-out/`, `*-workspace/`, `**/iteration-*/`).

SCORECARD numeric deltas come from **Tier 2**, not Tier 1. Do not add `skills-evals-soft` as a required branch-protection check.

## Publishing results

Update [docs/evals/SCORECARD.md](evals/SCORECARD.md) so adopters can decide keep / optional / replace.
