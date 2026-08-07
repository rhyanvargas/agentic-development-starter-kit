---
name: Skill eval artifact trail (iteration-N, benchmark.json, feedback.json)
overview: Close three agentskills.io-parity gaps in scripts/run-skill-evals-soft.sh so Tier 2 SCORECARD claims have a durable audit trail — versioned iterations instead of overwrite-in-place, script-computed benchmark.json instead of hand-arithmetic, and a feedback.json slot for human review notes. Script-only; no new dependency; no Tier 3 (LLM-in-CI) boundary crossed.
todos:
  - id: T1
    content: Add iteration-N/ auto-versioning inside package_skill() (next_iteration_dir helper); update package_all_skills/write_batch_artifacts to resolve each skill's latest iteration
    status: completed
  - id: T2
    content: Add feedback.json stub (one empty entry per real eval id) generated alongside grading.json stubs
    status: completed
  - id: T3
    content: Add --aggregate DIR mode that reads graded eval-*/grading.json + optional eval-canary, fails closed on PENDING or a passing canary, writes benchmark.json (pass-rate mean/stddev across cases + delta)
    status: completed
  - id: T4
    content: Extend run_self_test() — iteration bump on repeat package, feedback.json shape, aggregate happy path (hand-graded fixtures), aggregate fail-closed paths (PENDING left, canary PASS)
    status: completed
  - id: T5
    content: Update docs/evaluating-skills.md (iteration-N paths, benchmark.json, feedback.json, --aggregate usage) and script usage() text
    status: completed
  - id: T6
    content: Verify — check-skills-ci.sh, check-skills-ci.sh --self-test, run-skill-evals-soft.sh --self-test all green
    status: completed
isProject: false
---

# Skill eval artifact trail

## Why (evidence)

Discussed and agreed in-session: Tier 2 today loses the audit trail a maintainer or adopter would need to trust SCORECARD numbers.

- `scripts/run-skill-evals-soft.sh` `package_skill()` writes `eval-<id>/{with,without}_skill/grading.json` stubs directly into the caller's `--out` dir with no versioning — a second run overwrites the first (confirmed by re-running `--skill pull-request-authoring` into the same dir).
- `docs/evaluating-skills.md:88-92` already documents an `iteration-1/` workspace layout and `benchmark.json` aggregation (mirroring [agentskills.io](https://agentskills.io/skill-creation/evaluating-skills.md)), but no script produces either — `scorecard-paste.md`'s numbers are hand-computed arithmetic (`assertions PASS / total`) typed once by a human.
- `.gitignore:15` already ignores `**/iteration-*/`, i.e. iteration nesting was anticipated but never wired up.
- `feedback.json` (free-text human review per case, distinct from assertion grading) is implied by `eval-loop.md:41` ("Human feedback empty or only nits") but no artifact backs it.

## Scope

`scripts/run-skill-evals-soft.sh` + `docs/evaluating-skills.md` only. No new dependency, no CI-blocking gate, no change to Tier 1, no LLM call added anywhere (all three changes are deterministic bash/python over already-graded JSON).

## Changes

### 1. Iteration versioning

`package_skill(name, skill_root)` resolves the true output dir via a new `next_iteration_dir()` helper: scan `skill_root/iteration-*`, pick `max(N)+1` (or `1` if none exist), `mkdir -p` that path, and package into it. `package_all_skills()`/`write_batch_artifacts()` resolve each skill's **latest** iteration dir rather than assuming `iteration-1` (so weekly Tier 2 Actions runs accumulate instead of collapsing to one number).

### 2. `feedback.json` stub

Alongside the existing `grading.json`/`README.md` stubs, write one `feedback.json` at the iteration root: `{"eval-<id>": ""}` per real case (canary excluded — it's a grader-integrity check, not a quality-judgment case). Empty string = "no notes, looked fine" per agentskills.io convention. Add a `scorecard-paste.md` checklist line.

### 3. `--aggregate DIR` mode

New mode (parallel to `--self-test`): reads `DIR/cases.json` + each `DIR/eval-<id>/{with,without}_skill/grading.json`, computes per-arm pass rate per case, then mean/stddev **across cases** (explicitly labeled as such — not repeated-run variance) and a with-minus-without delta, and writes `DIR/benchmark.json`. Optional `timing.json` per arm folds into a token/duration delta when present.

Fail-closed (exit non-zero, no `benchmark.json` written):

- Any real case's `grading.json` still has a `PENDING` assertion result.
- `DIR/eval-canary/grading.json` exists and its recorded result is not `FAIL` (forward-compatible with the canary landing from the separate provenance-trust branch; if the canary dir doesn't exist yet, aggregate proceeds with a printed warning rather than hard-failing, since main doesn't generate a canary yet).

## Out of scope

- No change to Tier 1 (`check-skills-ci.sh`).
- No new required CI check; `--aggregate` is maintainer-run, same as the rest of Tier 2.
- No repeated-run statistics (running the same case N times) — stddev here is across the test-case set within one iteration, documented as such to avoid overclaiming.

## Verification

- `./scripts/check-skills-ci.sh` and `./scripts/check-skills-ci.sh --self-test` stay green (unrelated file).
- `./scripts/run-skill-evals-soft.sh --self-test` passes, covering: iteration bump, feedback.json shape, `--aggregate` happy path against hand-graded fixtures, and both fail-closed paths (PENDING left ungraded; canary graded PASS).
