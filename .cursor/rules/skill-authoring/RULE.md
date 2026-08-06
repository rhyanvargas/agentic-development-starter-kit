---
description: "Require Agent Skills optimization gates when creating or editing skills"
globs: "**/SKILL.md"
alwaysApply: false
---

# Skill authoring quality gate

When creating or editing skills in this repo or an ADSK adopter project, follow **`skill-optimizer`** (read that skill before drafting or “done”).

Also apply when the user asks to create, optimize, or review a skill — even if `SKILL.md` is not open yet.

## Must do

1. Read and apply `skill-optimizer` (kit: `skills/skill-optimizer`; adopter: `.agents/skills/skill-optimizer`).
2. Keep `SKILL.md` lean; put depth in `references/` with explicit when-to-load conditions.
3. Write `description` as what + when; add near-miss “Do not use for…” when adjacent skills share keywords.
4. Add/update `evals/trigger/eval_queries.json` (~20 queries, include near-misses) and behavior `evals/evals.json` when instructions change. For a with/without pass, use `/run-skill-evals`.
5. Run `./scripts/check-skills-ci.sh <skill-dir>` before claiming done — it runs `skills-ref validate` plus the line-budget and reference-depth gates that CI (Tier 1) enforces, so a local pass matches what CI will check.

## Layout

| Context | Path |
|---------|------|
| Kit source | `skills/<name>/` + symlinks under `.agents/skills/` and `.cursor/skills/` |
| Adopter app | `.agents/skills/<name>/` only |

After adding/removing a **kit** first-party skill, sync discovery links: `./scripts/sync-adsk.sh kit` (or `/sync-adsk` / “Sync ADSK”).

Do not duplicate the full optimizer playbook into commands or this rule.
