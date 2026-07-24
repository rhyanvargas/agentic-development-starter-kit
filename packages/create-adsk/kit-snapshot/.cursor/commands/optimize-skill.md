# /optimize-skill

Optimize an Agent Skill for trigger accuracy, clarity, and token cost.

## Skill

Read and follow **`skills/skill-optimizer`** (or `.agents/skills/skill-optimizer` in adopter apps).

## Usage

```
/optimize-skill
/optimize-skill skills/spec-driven-workflow
/optimize-skill .agents/skills/my-company-skill
```

## Behavior

1. Locate the target skill directory (ask if unclear).
2. Run the skill-optimizer gates (validate, description, lean body, progressive disclosure, trigger + output evals).
3. Apply lean edits; move kit-meta/rationale into `references/` with hard when-to-load conditions.
4. Report what changed and any remaining eval gaps. For a full with/without output pass, hand off to `/run-skill-evals` (that command must end with **Recommended next actions** from `skill-optimizer` → `references/eval-loop.md`).
