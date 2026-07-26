# Skill authoring (ADSK)

Conventions for first-party skills in this repo **and** adopter-owned skills.
Aligned with [agentskills.io](https://agentskills.io).

**Optimization is mandatory:** when creating or editing a skill, follow the
**`skill-optimizer`** skill (and `/optimize-skill` in Cursor). Do not ship a
skill that skips validation, trigger evals, or progressive-disclosure checks.

## Spec compliance

- Folder name matches YAML `name`
- `description` states **what** and **when** (trigger keywords); ≤ 1024 characters
- Prefer a near-miss boundary (“Do not use for…”) when adjacent skills share keywords
- Keep `SKILL.md` lean (&lt; ~500 lines / ~5k tokens; prefer much smaller)
- Put depth in `references/` (or `scripts/`) and tell the agent **when** to load each file

See:

- [Quickstart](https://agentskills.io/skill-creation/quickstart)
- [Best practices](https://agentskills.io/skill-creation/best-practices)
- [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- [Specification](https://agentskills.io/specification)
- Playbook: `skills/skill-optimizer/SKILL.md` (installed as `.agents/skills/skill-optimizer` for adopters)

## Progressive disclosure

1. **Catalog** — `name` + `description` at session start  
2. **Instructions** — full `SKILL.md` when activated  
3. **Resources** — references/scripts only when needed  

Token test for each paragraph: *Would the agent get this wrong without it?* If no, cut or move to a reference with a hard when-to-load condition.

**Always-on vs skill depth (lean steering):** Put stable constraints in rules / `AGENTS.md`. Put playbook depth in skills + `references/`. Thin Cursor commands should link to skills, not copy them. Prefer the kit Prefer table (Rules / Commands / Skills) over growing always-on text. Adopter org policy (survive kit updates): [customizing-org-rules.md](customizing-org-rules.md).

## Validation

```bash
npx --yes skills-ref validate ./skills/<skill-name>
# adopters:
npx --yes skills-ref validate ./.agents/skills/<skill-name>
```

(See current install notes on [agentskills.io specification — validation](https://agentskills.io/specification#validation).)

## Descriptions (trigger quality)

- Prefer agent-directed triggers (“Use when…”) plus concrete capability verbs
- Include near-miss negatives in the description and in trigger evals
- Maintain ~20 labeled queries in `evals/trigger/eval_queries.json` (~50/50)
- Optimize with a train/validation split; see [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)

## Output evals

Behavior changes need cases in `evals/evals.json`. Run with vs without skill and watch pass-rate and token deltas — [docs/evaluating-skills.md](evaluating-skills.md). Cursor: **`/run-skill-evals`**. Adopters: trust [evals/SCORECARD.md](evals/SCORECARD.md) for kit skills; re-run only when you change a skill or model.

## Layout

**This kit (package source):**

```
skills/<name>/
├── SKILL.md
├── references/
├── scripts/
└── evals/
.agents/skills/<name> → ../../skills/<name>
.cursor/skills/<name> → ../../skills/<name>
```

**Your app (adopter):** put skills only under `.agents/skills/<name>/` — [docs/using-adsk.md](using-adsk.md).

## Cursor wiring

| Artifact | Role |
|----------|------|
| Rule `.cursor/rules/skill-authoring/` | Quality gate when skill files are in context |
| Command `/optimize-skill` | Thin wrapper → `skill-optimizer` |
| Command `/run-skill-evals` | Thin wrapper → with/without output eval loop |
| Skill `skill-optimizer` | Full optimization playbook |

## Anti-patterns

- Duplicating the skill body into Cursor commands
- Vague instructions (“handle errors appropriately”) without project-specific procedure
- Loading every reference up front / soft “read the overview” triggers
- Kit-meta (slash-command catalogs, install notes) in the activation body
- Vendoring unpinned upstream skills into git without review
- Shipping without trigger near-misses or `skills-ref validate`
