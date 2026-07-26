# Spec Writing Guide

Write effective specifications for AI-assisted development.

## The Problem

Specs can fail in two ways:
1. **Too vague**: AI fills gaps with assumptions (often wrong)
2. **Too detailed**: Spec becomes harder to maintain than code

The goal is **just enough detail** to communicate intent clearly.

## Before you draft

### Surface assumptions

List assumptions and get correction *before* writing the body of the spec. Silent assumptions are the most expensive misunderstandings.

### Reframe vague goals

Translate fuzzy requests into concrete success criteria, then confirm with the human:

```
REQUIREMENT: "Make search better"
SUCCESS CRITERIA:
- Partial name match, case-insensitive
- Results return in < 300ms for 10k users
- Empty query shows paginated full list
→ Right targets?
```

### AI-ready language

Write for both humans and agents:

- Prefer precise, unambiguous wording; distinguish must / should / may
- Define acronyms and domain terms on first use
- Prefer structured headings, lists, and tables over prose walls
- Include examples and edge cases where behavior could fork
- Keep the spec self-contained (do not rely on chat history)

### Sketch preferred test seams (medium+)

Before locking requirements, name where you will prove the behavior from the outside:

1. Prefer an **existing** high seam (HTTP/API boundary, public module, port/adapter) over a new internal seam.
2. Prefer **fewer** seams — inventing many test doubles usually means the design is unclear.
3. Confirm seams with the user when they imply new interfaces or architecture.
4. Record seams under Testing / Strategy (or in a short “Test seams” note) so the plan can map `REQ-XXX` → seam → tests.

Do not put specific file paths or code snippets in the product half of a split spec — seams and interfaces belong in TECH / plan once product intent is stable.

## Entry mode: Requirements-First vs Design-First

Default is **Requirements-First** (behavior → optional TECH → plan).

| Mode | Start with | Then | Use when |
|------|------------|------|----------|
| **Requirements-First** (default) | Consumer-facing REQs / acceptance | Approach, plan, implement | Product features, flexible architecture |
| **Design-First** | TECH / approach (architecture, algorithms, NFRs) | Derive feasible REQs from that design | Strict latency/throughput/compliance, porting an existing design, feasibility before locking scope |

Design-First still ends in **testable REQs** before implement — design alone is not done. Prefer one file with Overview → Approach → Requirements unless a PRODUCT/TECH split helps review. Do **not** invent a mandatory three-file `.kiro/specs/` layout.

For non-trivial **bugs**, use `bugfix-workflow.md` (Current / Expected / Unchanged) instead of a feature entry mode.

## Functional vs Technical

### Functional Spec (What)
Lives in the feature spec document:
- User behavior and expectations (consumer POV — end user, caller, or agent)
- Acceptance criteria and invariants that must hold
- Business rules
- Constraints and edge cases
- Out of scope

Describe **what the consumer observes**, not internal types, state layout, or module graphs.

### Technical Spec (How)
Default home is project rules (`.cursor/rules/`) and conventions:
- Implementation patterns
- Framework conventions
- Coding standards
- Architecture decisions that apply across features

For **large** features that need both lenses, you may split:

| File | Contents |
|------|----------|
| `{feature}.md` or `PRODUCT.md` | Outcomes, consumer-facing behavior/invariants, acceptance, out of scope — **no** impl details |
| `{feature}-tech.md` or `TECH.md` | Approach, APIs, data model, migrations, test seams — only when the “how” is a decision, not a preference |

**When to split:** product intent and implementation tradeoffs both need review, or the tech section would dominate the product story. Prefer one file otherwise. Put both under the same artifact home (see `artifact-homes.md`); ticket-id folders (`specs/<id>/PRODUCT.md`) are fine when the project already uses that convention — do not invent Linear/Warp-specific layouts for portable apps.

### When to Add Technical Details to Spec

Add to the spec when:
- Rules don't cover the specific case
- Integration requires specific approach
- Performance constraints affect design
- Security requirements dictate implementation

**Example**: Spec normally wouldn't mention database:
```markdown
## Requirements
- Store user preferences
```

But if there's a constraint:
```markdown
## Requirements
- Store user preferences in Redis (not PostgreSQL) for fast access
```

## Spec Structure

### Minimal Spec (Small changes)
```markdown
# Feature Name

## Overview
One sentence: what and why.

## Requirements
- [ ] Requirement 1
- [ ] Requirement 2

## Acceptance Criteria
- Given X, when Y, then Z
```

### Standard Spec (Medium changes)
```markdown
# Feature Name

## Overview
What this does and why it matters.

## Assumptions
- [Assumptions already confirmed, or open ones marked]

## Requirements

### Functional
- [ ] REQ-001: User can do X
- [ ] REQ-002: System responds with Y

### Non-Functional
- [ ] Performance: responds in < 200ms
- [ ] Security: requires authentication

## Acceptance Criteria
- Given [context], when [action], then [result]

## Test Strategy
- REQ-001: {unit|integration|e2e} — {what to assert}
- REQ-002: {unit|integration|e2e} — {what to assert}

## Boundaries (optional, feature-scoped)
- Always: […]
- Ask first: […]
- Never: […]

## Constraints
- Must work with existing Z
- Cannot break backward compatibility

## Out of Scope
- Not included: A, B, C

## Open Questions
- [Anything unresolved]
```

Feature **Boundaries** (Always / Ask first / Never) are for *this change*. Project-wide commands, structure, and style belong in rules — not duplicated in every feature spec.

### Detailed Spec (Large/complex changes)
Add as needed:
- Data models
- API contracts
- State diagrams
- Error scenarios
- Migration strategy

## Writing Good Requirements

### Bad: Vague
```markdown
- User can search
```

### Better: Specific
```markdown
- User can search users by name (partial match, case-insensitive)
- User can search users by email (exact match)
- Search returns max 20 results per page
- Empty search shows all users (paginated)
```

### Bad: Implementation-focused
```markdown
- Create a SearchService class with findByName method
- Use SQL LIKE query for partial match
```

### Better: Behavior-focused
```markdown
- Search matches partial names (e.g., "john" matches "Johnny")
- Search is case-insensitive
```

## Acceptance Criteria

Prefer **Given-When-Then** (default). **EARS** is an optional equivalent when the team likes `WHEN` / `THE SYSTEM SHALL` — do not require both.

### Given-When-Then (default)

```markdown
## Acceptance Criteria

### Happy Path
- Given a user with name "John Doe"
- When I search for "john"
- Then the user appears in results

### Edge Cases
- Given no users match the search
- When I search for "xyz123"
- Then I see "No results found" message

### Error Handling
- Given the search service is unavailable
- When I search for anything
- Then I see a friendly error message
```

### EARS (optional)

```markdown
WHEN a user searches for a partial name
THE SYSTEM SHALL return matching users case-insensitively (max 20 per page)

WHEN no users match the search
THE SYSTEM SHALL display "No results found"
```

Keep `REQ-XXX` IDs either way so plans and tests stay traceable.

## Constraints Section

Document what limits the solution:

```markdown
## Constraints
- Must use existing User model (no schema changes)
- Must maintain backward compatibility with v1 API
- Must work offline (cached data)
- Performance: search completes in < 500ms
```

## Out of Scope

Explicitly state what you're NOT building:

```markdown
## Out of Scope
- Advanced filters (date range, status)
- Saved searches
- Search history
- Full-text search of user content
```

This prevents scope creep and clarifies boundaries.

## Common Mistakes

### 1. Assuming context
**Bad**: "Add the usual validation"
**Good**: "Validate email format, require @ and domain"

### 2. Mixing abstraction levels
**Bad**: Requirements mixing UI, API, and database details
**Good**: Separate functional (what) from technical (how)

### 3. Forgetting edge cases
**Bad**: Only describing happy path
**Good**: Include empty states, errors, limits

### 4. Being too prescriptive
**Bad**: "Create file X.ts with function Y that calls Z"
**Good**: "Enable users to do X" (let AI figure out how)

### 5. Skipping acceptance criteria
**Bad**: Vague "should work"
**Good**: Specific testable scenarios

## Tips

### Start with the user
"As a user, I want to..." forces you to think about value.

### Write tests first (mentally)
If you can't test it, you can't spec it. Prefer assigning `REQ-XXX` IDs so plans and tests can map cleanly back to requirements.

### Include examples
```markdown
## Examples
- Input: "john@example.com" → Valid
- Input: "john@" → Invalid (no domain)
- Input: "john" → Invalid (no @)
```

### Use checkboxes
They make specs actionable and trackable.

### Keep it living
Update specs when requirements change. Outdated specs are worse than no specs.

## Checklist

Before running `/implement-spec`:

- [ ] Ambiguous assumptions were surfaced and resolved (or listed as open questions)
- [ ] Overview explains what and why
- [ ] Requirements are specific and testable
- [ ] Acceptance criteria cover happy path (GWT or EARS)
- [ ] Edge cases documented
- [ ] Constraints stated
- [ ] Out of scope defined
- [ ] Preferred test seams named (medium+) and confirmed when they imply new boundaries
- [ ] Medium+: cross-requirement analyze done (or N/A) — see `analyze-requirements.md`
- [ ] Bugfix (if applicable): Unchanged fence present — see `bugfix-workflow.md`
- [ ] If PRODUCT/TECH split: product half stays consumer-facing; impl lives in TECH
- [ ] No implementation details in the product/requirements half (unless necessary)
- [ ] Spec is saved in the project (not only in chat)
- [ ] Plan/todos resynced if REQs changed after an earlier `/plan-impl`
