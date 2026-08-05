---
name: Skills best-practices review backlog
overview: Track follow-up items from the Aug 2026 review of first-party skills against Anthropic's Agent Skills best-practices doc. T1 (nested-reference flattening in spec-driven-workflow) is done; remaining items are CI-gate hardening, eval measurement gaps, and small consistency fixes.
todos:
  - id: T1
    content: Flatten same-skill reference-to-reference links in spec-driven-workflow (best-practices.md, getting-started.md, brownfield-workflow.md, greenfield-workflow.md, problem-size-guide.md, spec-driven-overview.md) so every cross-reference routes through SKILL.md's table instead of hopping reference-to-reference
    status: completed
  - id: T2
    content: "Extend scripts/check-skills-ci.sh with two Tier 1 gates: (a) SKILL.md line/token budget (<500 lines), (b) same-skill reference-to-reference link detector — mirror existing validate_* + fixture-mutation self-test pattern"
    status: completed
  - id: T3
    content: Add 'file references are one level deep' to skill-optimizer's Non-negotiable gates list (currently absent despite being graded elsewhere)
    status: completed
  - id: T4
    content: Populate model name + Token Δ columns in docs/evals/SCORECARD.md on next /run-skill-evals pass; add a reminder in skill-optimizer/references/eval-loop.md 'Do now' step to capture both before pasting into SCORECARD
    status: completed
  - id: T5
    content: Fix informal MCP reference in supply-chain-gate/references/dependency-intake.md to fully-qualified ServerName:tool_name form (or remove the specific tool mention if not load-bearing)
    status: completed
  - id: T6
    content: Document the gerund vs. noun-phrase skill-naming split as an accepted style note in docs/skill-authoring.md (do not rename existing skills — breaking change for adopters who reference them by name)
    status: completed
  - id: T7
    content: State the 'first-party skills ship no scripts/' trust posture explicitly in docs/evals/SCORECARD.md trust checklist item 4, so the absence reads as an intentional security posture rather than an inferred gap
    status: completed
isProject: false
---

# Skills best-practices review backlog

Source: review against [Anthropic Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md), run 2026-08-05 against `skills/*` (8 first-party skills).

## Context

The kit already self-enforces most of the doc via `skill-optimizer`, `docs/skill-authoring.md`, and a Tier 1/Tier 2 eval harness (`scripts/check-skills-ci.sh`, `docs/evals/SCORECARD.md`). Remaining gaps are places where the **automated gate lags the documented gate** — not missing conventions.

## T1 — Nested references (done)

`spec-driven-workflow` (shipped in every adopter profile via `core`) had reference files linking directly to sibling reference files instead of routing through `SKILL.md`'s progressive disclosure table — the doc's explicit anti-pattern ("Claude might use `head -100`... resulting in incomplete information"). Fixed by converting all same-skill `[Label](file.md)` links inside `references/*.md` to plain backticked filename mentions pointing back at `SKILL.md`'s table. Verified: `skills-ref validate` and `./scripts/check-skills-ci.sh` both green after the change.

## T2 — CI gate hardening (next highest leverage)

`check-skills-ci.sh` currently checks: `skills-ref validate`, frontmatter name == folder name, `evals.json` shape, `trigger/eval_queries.json` shape (n≥20, 40/60 balance). It does **not** check line/token budget or reference-depth, so a future PR could reintroduce T1's issue or exceed the 500-line budget and still pass CI.

Implementation sketch (mirror existing pattern):
- `validate_line_budget()` — `wc -l SKILL.md`, fail (or warn) over threshold
- `validate_reference_depth()` — grep `references/*.md` for `\]\([a-z-]+\.md\)` matches that resolve to a sibling file in the same `references/` dir; fail if found
- Add both to `check_skill_dir()`, plus mutation fixtures in `run_self_test()` (oversized SKILL.md; a reference-to-reference link)

## T3–T7 — Smaller fixes

Independent, low-risk, can be done in any order or batched into one PR:
- T3: one line added to `skill-optimizer/SKILL.md`'s gate list
- T4: SCORECARD schema already has the columns; just needs data + a process reminder
- T5: one-line wording fix in `supply-chain-gate/references/dependency-intake.md`
- T6: doc-only addition to `docs/skill-authoring.md`
- T7: doc-only addition to `docs/evals/SCORECARD.md`

## Done when

- T2: `check-skills-ci.sh --self-test` covers both new gate classes; full run stays green on `skills/*`
- T3–T7: each shipped as a small, reviewable diff; no `skills-ref validate` or Tier 1 regressions

## Progress (2026-08-05)

All T2–T7 implemented and verified green (`./scripts/check-skills-ci.sh --self-test` and full run on `skills/*`):

- **T2** — Added `validate_line_budget()` (500-line cap) and `validate_reference_depth()` (flags `](sibling.md)` links within the same skill's `references/`) to `scripts/check-skills-ci.sh`, wired into `check_skill_dir()`, plus two new mutation fixtures (oversized `SKILL.md`, a same-dir reference link) in `run_self_test()`.
- **T3** — Added gate 6 ("Reference depth") to `skills/skill-optimizer/SKILL.md`'s Non-negotiable gates list, citing the new CI enforcement.
- **T4** — Added a "capture model name + Token Δ before pasting" reminder to `skills/skill-optimizer/references/eval-loop.md`'s Recommended-next-actions section. The actual column population is explicitly gated on the **next** `/run-skill-evals` Tier 2 pass — not fabricated in this session.
- **T5** — Reworded the Socket MCP mention in `skills/supply-chain-gate/references/dependency-intake.md` from a specific (unverified) tool name to a generic "Socket MCP server if configured" — no fully-qualified `ServerName:tool_name` convention exists elsewhere in the repo to match, and the specific name wasn't load-bearing.
- **T6** — Added a "Naming style" section to `docs/skill-authoring.md` documenting the gerund vs. noun-phrase split as accepted style, explicitly forbidding renames.
- **T7** — Extended trust-checklist item 4 in `docs/evals/SCORECARD.md` to state the no-`scripts/`-in-first-party posture explicitly.

**Git expectation:** all changes are uncommitted in the working tree; no commit made per no explicit user request to commit.
