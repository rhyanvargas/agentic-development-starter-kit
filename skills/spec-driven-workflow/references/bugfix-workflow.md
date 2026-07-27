# Bugfix Workflow

Surgical fixes for non-obvious or high-risk bugs. Explicitly fence **unchanged** behavior so agents do not “fix” by rewriting neighbors.

## When to use

| Use bugfix path | Skip (chat / trivial) |
|-------------------|------------------------|
| Root cause unclear | Typo, obvious one-liner |
| Critical path (auth, payments, data) | Purely local rename |
| Prior fix caused regressions | Clear cause + tiny blast radius |
| Need a durable record of defect + fence | |

Size still applies: Small may be bugfix spec → implement; Medium+ add plan + review.

## Artifact

Prefer one file under the resolved spec home (e.g. `{area}-bugfix.md`), or a **Bugfix** section in a short change spec. Do **not** invent a `.kiro/specs/` triad.

### Template

```markdown
# Bugfix: {short title}

## Overview
One sentence: what fails and who is affected.

## Current behavior (defect)
- WHEN [condition] THEN the system [incorrect behavior]
- Reproduction steps: …

## Expected behavior (correct)
- WHEN [condition] THEN the system SHALL [correct behavior]
- REQ-FIX-001: …

## Unchanged behavior (regression fence)
Behaviors that must keep working — write these even if “obvious”:
- WHEN [condition] THEN the system SHALL CONTINUE TO [existing behavior]
- REQ-KEEP-001: …
- REQ-KEEP-002: …

## Assumptions
- …

## Constraints
- Files/modules that should not change (if any)
- Compatibility / rollback notes

## Test strategy
- Reproduce current defect (failing test or manual repro) before the fix
- Assert expected behavior after the fix
- Cover each Unchanged item (automated preferred)
- Preferred test seam: …

## Out of scope
- New features discovered during RCA (spawn a feature spec instead)
```

EARS-style `WHEN` / `SHALL` / `SHALL CONTINUE TO` is encouraged here; Given/When/Then is fine if equivalent and testable.

## Procedure

1. **Size** — Trivial → chat. Else continue.
2. **Draft bugfix** — Fill Current / Expected / Unchanged before designing the fix.
3. **Analyze** (Medium+) — Read `analyze-requirements.md` across FIX + KEEP items.
4. **Plan** (Medium+) — Root-cause-informed tasks; map tests to FIX and KEEP REQs. Tracer if the fix path is architecturally unclear.
5. **Clear → Implement → Review** — Fail-closed verify. Review must check the regression fence, not only the fix.

## Anti-patterns

- Fixing without documenting Unchanged (agents expand blast radius)
- Turning a bugfix into a feature dump mid-stream — split a feature spec
- Skipping a failing repro before claiming the bug is fixed
