# Lifecycle coverage (ADSK)

How The Agentic Development Starter Kit maps to enterprise product delivery stages.

## Map

| Stage | Coverage | Mechanism |
|-------|----------|-----------|
| Ideate / discover | **Optional (recommended pack)** | Product value loop: wondelai (`inspired-product`, `mom-test`, `continuous-discovery`, `jobs-to-be-done`) — see [product-value-loop.md](product-value-loop.md) |
| Research (market / competitors) | **Optional** | Anthropic `competitive-intelligence` (+ loop doc) |
| Prioritize | **Optional** | OST + opportunity assessment + `prioritization-advisor` |
| Plan / organize | **Core** | First-party `spec-driven-workflow` + recommended `writing-plans`; product roadmaps via `roadmap-planning` / `product-strategy-session` |
| Design (system) | **Core (delivery+)** | First-party `solution-architecture` (C4 views, ADRs, risks; `/design-architecture`); SDD plan gate for Large / ambiguous Medium |
| Design (UI) | Optional | `frontend-design` (Anthropic) via recommended optional list |
| Develop | **Core** | SDD implement + recommended TDD |
| Test | **Core** | Recommended TDD + Cursor `testing` / `project-cmds` rules in consumer projects |
| Deploy | **Core (strategy)** | First-party `devops-strategy-facilitator` (strategy, not full pipelines) |
| Release / changelog | **Core** | First-party `release-automation` (+ Cursor `/setup-releases`; platform-confirmed) |
| Secure | **Recommended (baseline)** | Kit: Dependabot + `npm audit` CI + Trusted Publishing for `create-adsk` ([SECURITY.md](../SECURITY.md)); skills: `dependabot`, `npm-security-best-practices`. Broader AppSec still via org-approved review |
| Maintain / monitor | **Gap (v1)** | Observability minimums only inside DevOps strategy template |
| Debug | **Recommended** | Superpowers `systematic-debugging` |
| Author agent skills | **Core** | First-party `skill-optimizer` (+ Cursor `skill-authoring` rule / `/optimize-skill`) |
| Document (README) | **Core** | First-party `readme-authoring` (+ Cursor `/update-readme`) |
| Pull requests | **Core (maintainer)** | First-party `pull-request-authoring` (+ Cursor `/create-pr`) — commit-derived PR bodies |
| Secure / supply chain | **Core (maintainer)** | First-party `supply-chain-gate` (+ `/setup-socket`); Dependabot + npm audit + Socket CI |

## Best workflow (product → delivery)

When maximizing customer value (not just shipping features):

```text
Discover → Research → Prioritize → Plan → Execute → measure → Discover
```

Full playbook and install commands: **[product-value-loop.md](product-value-loop.md)**.

## First-party vs recommended

```text
ADSK first-party (in this repo)
├── spec-driven-workflow     → specify, plan, implement, review, brownfield
├── solution-architecture    → sized C4 packets, ADRs, risks (+ `/design-architecture`)
├── devops-strategy-facilitator → delivery strategy decisions
├── release-automation       → Conventional Commits changelog/semver (GH or Azure)
├── skill-optimizer          → create/optimize skills (triggers, tokens, evals)
├── readme-authoring         → evidence-grounded README create/update/review
├── supply-chain-gate        → Socket / supply-chain PR triage + dependency intake
└── pull-request-authoring   → commit-derived GitHub PR title/body (+ `/create-pr`)


Recommended upstream (pinned in recommended-skills.json)
├── obra/superpowers         → plans, TDD, debug, review habits
├── vercel-labs find-skills  → safe discovery under trust policy
├── anthropics skill-creator → maintainers / eval automation
├── github/awesome-copilot dependabot → Dependabot YAML / update workflows
├── aradotso npm-security-best-practices → npm install hardening guidance
└── optional product value loop
    ├── wondelai             → inspired-product, mom-test, continuous-discovery, JTBD
    ├── deanpeters           → strategy session, roadmap, prioritization
    └── anthropics           → competitive-intelligence

Do not add overlapping SDD packs (`to-prd`/`to-spec`/`to-tickets`, Addy/Warp SDD, …) — see recommended-skills.json do_not_add.overlapping-sdd
```

## Trust criteria

Do **not** install arbitrary skills.sh long-tail packages into production teams.

Prefer:

1. Official or well-known orgs (`anthropics`, `vercel-labs`, `obra`, …) or high-adoption maintainers after review
2. Compatible open-source license
3. Strong adoption signal
4. Human review of `SKILL.md` and `scripts/`
5. Pinned versions with intentional upgrades

Machine-readable list: [`recommended-skills.json`](../recommended-skills.json).  
Decision scorecard: [`docs/evals/SCORECARD.md`](evals/SCORECARD.md).

## Extending coverage

When extending Secure beyond the npm/Dependabot baseline, or filling Monitor gaps:

1. Prefer a **thin first-party skill** if the procedure is company-critical and must be portable.
2. Or add a **pinned recommended** entry after trust review.
3. Add eval cases so teams can compare before/after.

See [docs/skill-authoring.md](skill-authoring.md) and [CONTRIBUTING.md](../CONTRIBUTING.md).
