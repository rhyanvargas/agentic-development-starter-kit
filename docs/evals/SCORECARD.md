# ADSK skill scorecard

Decision aid for adopters: which skills to keep, treat as optional, or skip.

This table is the published **skill ground truth** for first-party ADSK skills (with/without-skill pass rates). Delivery work still needs **delivery ground truth** (specs + fail-closed verify) — see [evaluating-skills.md § Ground truth](../evaluating-skills.md#ground-truth-adsk). Upstream / pack skills are **not** scored here; use the [trust checklist](#trust-checklist-any-upstream-skill).

Scoring axes (1–5): **Fit** (lifecycle value), **Portability**, **Clarity**, **Trust**, **Eval readiness**.

## First-party skills

| Skill | Fit | Portability | Clarity | Trust | Eval readiness | Disposition | Notes |
|-------|-----|-------------|---------|-------|----------------|-------------|-------|
| `spec-driven-workflow` | 5 | 5 | 4 | 5 (in-repo Apache-2.0) | 5 (Tier 2 iter 3) | **Keep (core)** | Kit spine: specify → plan → implement → review + brownfield |
| `devops-strategy-facilitator` | 4 | 5 | 5 | 5 | 5 (Tier 2 iter 3) | **Keep** | Decision-first strategy sessions; not a full SRE pack |
| `release-automation` | 5 | 5 | 5 | 5 | 5 (Tier 2 iter 3) | **Keep** | Platform-confirmed changelog/semver (GitHub release-please or Azure + git-cliff); strongest Δ this run |
| `skill-optimizer` | 5 | 5 | 5 | 5 | 5 (Tier 2 iter 3) | **Keep** | Author/optimize skills; required gate; `/run-skill-evals` ends with next actions |
| `readme-authoring` | 4 | 5 | 5 | 5 (in-repo Apache-2.0) | 5 (Tier 2 iter 4) | **Keep** | Audience-aware + evidence-grounded README craft; flag-hygiene fix landed |
| `pull-request-authoring` | 5 | 5 | 5 | 5 | 5 (Tier 2 iter 3) | **Keep** | Conventional Commits PR title/body via `gh` |
| `supply-chain-gate` | 5 | 5 | 5 | 5 | 5 (Tier 2 iter 4) | **Keep** | Socket / dependency merge triage; policy-cite requirement landed |

### How to interpret “Eval readiness”

Cases and assertions live under each skill’s `evals/`. Published **with vs without** numeric deltas appear here after a **Tier 2** run (see [docs/evaluating-skills.md](../evaluating-skills.md)); Tier 1 CI only checks harness integrity, not pass rates. Until Tier 2 numbers exist, treat readiness as “harness ready,” not “benchmarked on your model.”

### How to fill results from a Tier 2 package

1. Generate (or download the Actions artifact from **skills-evals-soft**), or ask the agent **`/run-skill-evals`**:
   ```bash
   ./scripts/run-skill-evals-soft.sh
   # or one skill: ./scripts/run-skill-evals-soft.sh --skill skill-optimizer
   ```
2. Complete with/without runs and grade `eval-*/**/grading.json`.
3. Copy the **Aggregate** table from `.adsk-tier2-out/<skill>/scorecard-paste.md` into the template below (replace `_TBD_` for that skill).
4. Optionally bump **Eval readiness** to 5 and note the iteration date in **Notes**.

Adopters deciding keep/optional/replace: use the published table below; re-run only when you change the skill or model ([evaluating-skills.md](../evaluating-skills.md#adopters-first)).

**Current Tier 2 results** (ask-mode; isolated workspaces; LLM-graded; token Δ n/a). Iteration 3 = full first-party re-grade; iteration 4 = targeted fixes + re-run for readme / supply-chain (2026-07-24):

| Skill | Iteration | with_skill pass_rate | without_skill pass_rate | Δ pass_rate | Token Δ | Recommendation |
|-------|-----------|----------------------|-------------------------|-------------|---------|----------------|
| `devops-strategy-facilitator` | 3 | 1.0 (17/17) | 0.941 (16/17) | +0.059 | n/a | keep |
| `pull-request-authoring` | 3 | 1.0 (13/13) | 0.846 (11/13) | +0.154 | n/a | keep |
| `readme-authoring` | 4 | 1.0 (21/21) | 0.905 (19/21) | +0.095 | n/a | keep |
| `release-automation` | 3 | 1.0 (14/14) | 0.643 (9/14) | +0.357 | n/a | keep |
| `skill-optimizer` | 3 | 1.0 (15/15) | 0.667 (10/15) | +0.333 | n/a | keep |
| `spec-driven-workflow` | 3 | 1.0 (27/27) | 0.926 (25/27) | +0.074 | n/a | keep |
| `supply-chain-gate` | 4 | 1.0 (13/13) | 0.692 (9/13) | +0.308 | n/a | keep |

## Recommended upstream (not vendored)

| Source / skill | Fit | Trust signals | Coupling / risks | Disposition |
|----------------|-----|---------------|------------------|-------------|
| `obra/superpowers` (`writing-plans`, `test-driven-development`, `systematic-debugging`, …) | 5 for eng discipline | Very high adoption / public repo | May assume Superpowers paths (e.g. `docs/superpowers/`); pin and review updates | **Recommend (pinned)** |
| `vercel-labs/skills` → `find-skills` | 4 for discovery | Official Vercel Labs CLI ecosystem | Encourages registry installs — still apply trust checklist | **Recommend (pinned)** |
| `anthropics/skills` → `skill-creator` | 4 for maintainers/evals | Official Anthropic; Apache-2.0 | Maintainer-oriented; not required for every developer | **Recommend (maintainers)** |
| `anthropics/skills` → `frontend-design` | 3 (UI) | Official + high installs | UI craft only | **Optional** |
| Product value loop (wondelai / deanpeters / `competitive-intelligence`) | 5 for product teams | See per-source notes in `recommended-skills.json` | Install in **adopter apps** only; never vendor into kit | **Optional** — [product-value-loop.md](../product-value-loop.md) |
| Overlapping SDD skills (`to-prd`→`to-spec`, `to-tickets`, Addy/Warp SDD, `create-specification`) | — | Varies | Collides with first-party SDD; competing tracker spine | **Do not add** |
| Overlapping README skills (`crafting-effective-readmes`, `accelint-readme-writer`, …) | — | Varies | Collides with first-party `readme-authoring` | **Do not add** |

## Gaps (v1)

| Stage | Status |
|-------|--------|
| Secure (security review skill) | Not first-party yet — search via `find-skills` under org policy, or add later |
| Maintain / monitor (SRE) | Partial via DevOps observability questions only |

## Trust checklist (any upstream skill)

Before enabling in a company environment:

1. Source org / maintainer reputation  
2. License compatible with your policy  
3. Install/star signal (prefer well-known packs)  
4. Review `SKILL.md` + `scripts/` for exfiltration or credential prompts  
5. Pin version; re-review on upgrade  

See [`recommended-skills.json`](../../recommended-skills.json) and [lifecycle-coverage.md](../lifecycle-coverage.md).
