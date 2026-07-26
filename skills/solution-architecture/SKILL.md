---
name: solution-architecture
description: >-
  Design sized solution-architecture packets: outcome brief, C4 views
  (context, container, dynamic, deployment), ADRs, and a lite risk register.
  Use when the user wants an architecture diagram, C4 model, system context,
  container view, deployment/trust boundaries, ADR, architecture review, or
  /design-architecture. Do not use for feature REQ drafting (use
  spec-driven-workflow), CI/CD or promotion strategy (use
  devops-strategy-facilitator), README sync, or vendor-icon / draw.io rendering
  alone.
---

# Solution Architecture

Architecture is the set of **decisions**. Diagrams are focused views used to communicate, evaluate, and operate those decisions.

## Principles

- **Logical first, vendor second** — responsibilities and trust boundaries before cloud icons.
- **One view, one question** — split diagrams before they need a narrator.
- **Size the rigor** — match packet depth to problem size (table below).
- **Decisions over decoration** — stop adding detail until a decision, risk, ownership gap, or failure mode needs clarity.
- **Link to SDD** — living specs own requirements; this skill owns architecture views and irreversible choices.

## Size → packet depth

| Size | Minimum packet |
|------|----------------|
| Trivial / Small | Skip, or one context sketch inside the feature spec |
| Medium (architecture/integration ambiguous) | Brief + context + container + one dynamic flow + top ADRs/risks |
| Large | Above + deployment/trust view + scenario walk (success + ≥3 failure/misuse) |
| AI / agentic systems | Large packet + AI lifecycle/governance view (load AI reference) |

## SCALER procedure

1. **Scope** — One-page architecture brief (outcome, users, in/out of scope, top 3 quality attributes, constraints, assumptions, open decisions). Template: `references/architecture-brief.md`.
2. **Capture** — Confirm functional needs and quality attributes from the living spec (or draft them if none exists). Do not replace SDD for feature REQs.
3. **Arrange** — List logical responsibilities; apply the five-question box test (`references/c4-views.md`).
4. **Lay out** — Produce only the views required by size. Standards: `references/diagram-standards.md`.
5. **Evaluate** — ADRs for irreversible choices; lite risk/trade-off register. Templates: `references/adr-template.md`, `references/risk-tradeoffs.md`.
6. **Review** — Walk context → success path → high-impact failures → residual risk → owners/actions. Checklist: `references/review-checklist.md`.

## Artifact homes

Resolve output home before writing (same order as SDD `artifact-homes`):

1. Explicit path from the user
2. Existing `docs/architecture/` (or project architecture convention)
3. Client default — Cursor → `.cursor/docs/architecture/`; otherwise → `docs/architecture/`

Link the packet from the living spec/plan. Prefer Mermaid or linked diagram sources in version control; do not embed secrets or exploit-sensitive detail.

## Boundaries

| Need | Skill |
|------|--------|
| Testable feature requirements / plan / implement | `spec-driven-workflow` |
| Branching, CI/CD, env promotion, rollback strategy | `devops-strategy-facilitator` |
| Changelog / semver automation | `release-automation` |
| Vendor-icon or draw.io rendering | Optional upstream tooling — after logical views exist |

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/architecture-brief.md` | Drafting or reviewing the one-page brief |
| `references/c4-views.md` | Choosing or drafting context/container/dynamic/deployment views |
| `references/diagram-standards.md` | Headers, legends, trust boundaries, readability rules |
| `references/adr-template.md` | Recording a major architecture decision |
| `references/risk-tradeoffs.md` | Building the lite risk / trade-off register |
| `references/review-checklist.md` | Architecture review or print-ready done check |
| `references/ai-extensions.md` | System includes agents, models, retrieval, or tool-calling |
| `references/official-sources.md` | User asks for canonical external references |

`/design-architecture` is a thin Cursor wrapper that invokes this skill.
