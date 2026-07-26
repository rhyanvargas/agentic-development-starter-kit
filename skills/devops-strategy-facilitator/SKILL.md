---
name: devops-strategy-facilitator
description: >-
  Facilitate a concise DevOps strategy session covering branching, CI/CD,
  environments, promotion, governance, artifacts, secrets, and rollback.
  Use when designing or refining delivery strategy, environment promotion,
  deployment governance, or when /design-devops-strategy is invoked. Do not
  use for wiring release-please/changelog automation (use release-automation),
  Socket/supply-chain PR triage (use supply-chain-gate), C4/solution
  architecture packets (use solution-architecture), feature specs, writing
  Dockerfiles or a single app pipeline, unit tests, or debugging one failed CI
  run.
---

# DevOps Strategy Facilitator

Design a DevOps strategy that is **explicit, minimal, and adoptable**.

## Principles

- **Decision-first**: force choices; do not write prose essays.
- **Build once, promote** by default (unless constraints require rebuilds).
- **Environment-agnostic code**: configuration via deployment tooling, not code branches.
- **Least privilege + auditability**: especially for production deployments.
- **Keep it short**: prefer tables and checklists (about 1–2 pages).

## Session flow

1. **Context** (brief) — Platform (ADO/GHA/GitLab), runtime (K8s/PaaS/VM), IaC, compliance needs.
2. **Decisions** (5–10 questions max) — Branching, CI, artifacts, CD promotion, secrets, rollback, observability minimums.
3. **Draft** — Produce a strategy doc using `references/strategy-template.md`.
4. **Validate** — Call out risks, open questions, and explicit non-goals.

## Question bank (pick only what you need)

- **Platform**: Which CI/CD platform(s)? Mandated tooling?
- **Runtime**: K8s, App Service, Functions, VMs, other?
- **Envs**: What environments exist; what approvals are required?
- **Promotion**: Build once → promote, or rebuild per env? Why?
- **Release cadence**: continuous, weekly, or date-based release branches?
- **Compliance**: change control, separation of duties, evidence needs?
- **Artifacts**: images, zip packages, helm charts; where stored?
- **Secrets**: store and injection (vault, OIDC, service connections)?
- **Rollback**: blue/green, canary, redeploy previous artifact, DB plan?
- **Observability**: minimum logging/metrics/tracing + alerting?

## Output requirements

- Mark assumptions explicitly.
- Include a **Decision Log** table.
- End with optional **Next steps** (repo layout, pipeline skeleton, agent rules).

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/strategy-template.md` | When drafting or reviewing the strategy document |

`/design-devops-strategy` is a thin Cursor wrapper that invokes this skill.
