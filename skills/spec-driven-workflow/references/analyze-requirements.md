# Analyze Requirements

Cross-requirement pass **before** `/plan-impl` on Medium+ (and Large). Catches issues a single-REQ read-through misses.

Skip for Small/trivial or when the REQ set is tiny and already reviewed.

## When to run

- After the living spec’s requirements are drafted (or edited materially)
- Before generating or regenerating the implementation plan
- After Quick/Small-path auto-drafts that skipped a careful review
- Domain-sensitive work (auth, payments, compliance, data integrity)

## Checklist

Reason across the **full** REQ set (not each item alone):

| Check | Look for |
|-------|----------|
| **Conflicts** | Two REQs that cannot both be true |
| **Ambiguity** | “fast”, “large”, “secure”, “soon” without measurable criteria |
| **Constraint clashes** | Functional + NFR that cannot all be satisfied |
| **Unstated assumptions** | Undefined actors, systems, or terms |
| **Missing edges** | Failure modes, boundaries, empty states, concurrency, authz |
| **Trace gaps** | Acceptance / test strategy that does not cover a REQ |

## Output shape

Present findings as clarifying questions (or a short findings list). For each issue:

1. REQ IDs involved
2. Plain-language problem
3. Suggested fix (or “intentional — leave as-is”)

Update the living spec as the user resolves items. Do **not** invent resolutions silently.

```
ANALYZE FINDINGS:
1. REQ-002 vs REQ-005 — …
   Suggested: …
2. REQ-007 — ambiguous “fast”
   Suggested success criteria: …
→ Resolve these before /plan-impl?
```

## Done

- Material findings resolved or listed under Open Questions
- Spec updated (living)
- Safe to `/plan-impl` (or re-run plan sync if a plan already exists)
