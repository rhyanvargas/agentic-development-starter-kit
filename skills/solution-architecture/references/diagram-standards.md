# Diagram standards

Load when drafting or reviewing any architecture diagram.

## Header (required on every diagram)

```text
Title: [system] - [view name]
Purpose: [question this view answers]
Audience: [roles]
Scope: [included and excluded]
Owner: [team or role]
Status: Draft | Review | Approved | Superseded
Last updated: YYYY-MM-DD
Related ADRs: ADR-###
```

## Rules

- One diagram → one question. Split before text becomes unreadable.
- Consistent shapes/colors for people, systems, data stores, external services, trust boundaries.
- Label arrows with purpose, protocol, data type, and direction when material.
- Distinguish logical components from deployed technology / managed services.
- Show security and trust boundaries explicitly (not by spacing alone).
- Mark sync vs async when behavior differs.
- Include a legend; define abbreviations.
- Never put secrets, real credentials, protected data, or exploit-sensitive detail in broadly shared diagrams.
- Keep source in version control; link major changes to ADRs or PRs.

## Stop condition

Do not add more diagram detail until the current view exposes a decision, dependency, risk, ownership gap, or operational behavior that needs to be understood.
