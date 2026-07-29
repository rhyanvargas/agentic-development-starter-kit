# Best Practices

Proven patterns for effective AI-assisted development.

## Cursor Agent Best Practices

Based on [Cursor's official guidance](https://cursor.com/blog/agent-best-practices):

### Start with plans

> "The most impactful change you can make is planning before coding."

- Use Plan Mode (Shift+Tab) for medium+ tasks
- Let the agent research and ask questions
- Review and edit plans before implementing
- Save plans to the resolved plan home (Cursor: `.cursor/plans/` with YAML `todos`; portable: `docs/plans/`)

### Write specific prompts

> "The agent's success rate improves significantly with specific instructions."

**Vague** (less reliable):
```
Add tests for auth.ts
```

**Specific** (more reliable):
```
Write a test case for auth.ts covering the logout edge case, 
using the patterns in `__tests__/` and avoiding mocks.
```

### Iterate on setup

> "Start simple. Add rules only when you notice the agent making the same mistake repeatedly."

- Don't over-engineer your rules upfront
- Add rules when patterns emerge
- Add commands for workflows you repeat
- Remove rules that aren't helping

### Review carefully

> "AI-generated code can look right while being subtly wrong."

- Read diffs before accepting
- Understand the logic, don't just scan
- The faster the agent, the more important review becomes
- Use `/review` for systematic checks

### Provide verifiable goals

> "Agents can't fix what they don't know about."

- Use typed languages
- Configure linters
- Write tests
- Give clear success criteria

### Treat agents as collaborators

> "Ask for plans. Request explanations. Push back on approaches you don't like."

- Ask "why" when something seems off
- Request alternatives
- Refine specs based on feedback
- Course-correct early

---

## Spec-Driven Best Practices

### Keep specs small

One feature per spec. If it's too big:
- Split into sub-features
- Create separate specs
- Link them together

### Be behavior-focused

**Don't**: Describe implementation
```
Create a UserService class with findByEmail method
```

**Do**: Describe behavior
```
User can be found by email address (exact match)
```

### Include examples

Examples reduce ambiguity:
```markdown
## Examples
- Input: "john@example.com" → User found
- Input: "JOHN@example.com" → User found (case-insensitive)
- Input: "nonexistent@example.com" → 404 Not Found
```

### Define what's out of scope

Prevent scope creep:
```markdown
## Out of Scope
- Password reset flow
- Social login
- Multi-factor authentication
```

### Keep the spec alive

- Update the spec when decisions or scope change (before coding the change when possible)
- After material REQ edits, **resync the plan** (`/plan-impl` or refresh Cursor YAML `todos`) before implement
- Commit specs with the code
- Reference `REQ-XXX` or spec sections in PRs

### Analyze before planning (medium+)

Cross-check the full REQ set for conflicts, ambiguity, and missing edges (`analyze-requirements.md`) before `/plan-impl`. Skip only when the set is tiny and already reviewed.

### Bugfix with a regression fence

For non-trivial bugs, document Current / Expected / **Unchanged** (`bugfix-workflow.md`) so the fix does not rewrite neighbors.

### Common rationalizations

| Rationalization | Reality |
|---|---|
| "This is simple, I don't need a spec" | Simple work needs short acceptance criteria, not a novel |
| "I'll write the spec after I code" | That is documentation, not specification |
| "The spec will slow us down" | A short gated spec prevents expensive rework |
| "Requirements will change anyway" | Living specs absorb change; chat history does not |
| "The user knows what they want" | Clear requests still hide assumptions — surface them |

---

## Workflow Best Practices

### Match workflow to problem size

| Size | Workflow |
|------|----------|
| Trivial | Skip it, just do it |
| Small | Spec → Implement |
| Medium | Spec → Plan → Implement → Review |
| Large | Research → Spec → Plan → Implement → Review |

See [Problem Size Guide](problem-size-guide.md).

### Fail fast

If the agent is going wrong:
1. Press Escape to stop
2. Clarify the requirement
3. Restart fresh

Fixing mid-stream often makes things worse.

### Clear before implement (Medium+)

Explore → Plan → **Clear** → Implement:
- Bound exploration (subagent or dedicated chat OK)
- Persist durable findings into the living spec and/or plan
- Start implement lean — do not carry the full exploration transcript as working context
- Multi-session: read **Handoff / Progress** before coding; write it when ending incomplete Medium+ work (`session-handoff.md`) — not an AFK product
- Reference specific files and the living artifacts; re-state constraints when they matter

### Review as evaluator (Medium+)

After implement, run a separate refute-minded `/review` (`review-evaluator.md`). Implement self-grade is not “done.” For bugfixes, the Unchanged/KEEP fence is mandatory in review.

---

## Code Quality Best Practices

### Tests are non-negotiable

For any non-trivial change:
- Write tests with implementation
- Cover happy path and edge cases
- Run tests before committing

### Linting is automatic

Configure linters and let the agent:
- Fix style issues automatically
- Focus on logic, not formatting
- Maintain consistency

### Small commits

After each logical unit:
- Commit working code
- Write clear commit messages
- Make rollback easy

---

## Brownfield Best Practices

### Document before changing

For existing code:
1. Use `/extract-spec` first
2. Understand current behavior
3. Then write change spec

### Preserve backward compatibility

Unless explicitly breaking:
- Keep existing interfaces
- Add, don't replace
- Deprecate before removing

### Strangle, don't rewrite

Big rewrites fail. Instead:
- Make small spec-driven changes
- New code wraps old code
- Old code shrinks over time

---

## Anti-Patterns to Avoid

### Spec theater

Don't write specs for trivial changes:
- Typos don't need specs
- 1-line fixes don't need plans
- Use judgment

### Review blindness

Don't auto-approve:
- Read every diff
- Understand the changes
- Test manually for important features

### Rule bloat

Don't over-constrain:
- Too many rules confuse the agent
- Conflicting rules cause problems
- Keep rules minimal and focused

### Spec drift

Don't let specs rot:
- Update specs with requirements
- Archive completed specs
- Delete obsolete specs

---

## References

### Cursor
- [Agent Best Practices](https://cursor.com/blog/agent-best-practices)
- [Cursor Documentation](https://cursor.com/docs)

### Spec-Driven Development
- [Martin Fowler: Understanding SDD](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Alex Merced: AI-Assisted Coding Guide](https://dev.to/alexmercedcoder/a-practical-guide-to-ai-assisted-coding-tools-2fh5)
- [Kiro Specs](https://kiro.dev/docs/specs.md) — reference for gated requirements/design/tasks, Analyze Requirements, and Bugfix Current/Expected/Unchanged (absorb patterns; do not vendor `.kiro/specs/` layout or PBT-as-core)
- Patterns absorbed (not vendored): [addyosmani/agent-skills@spec-driven-development](https://skills.sh/addyosmani/agent-skills/spec-driven-development) (assumption surfacing, gated phases, success-criteria reframing); [github/awesome-copilot@create-specification](https://skills.sh/github/awesome-copilot/create-specification) (AI-ready language); [mattpocock/skills@to-spec](https://skills.sh/mattpocock/skills/to-spec) (preferred test seams — formerly `to-prd`); [warpdotdev/common-skills@write-product-spec](https://skills.sh/warpdotdev/common-skills/write-product-spec) (consumer-facing PRODUCT half vs TECH)

### General AI Coding
- [Anthropic: Claude Best Practices](https://docs.anthropic.com/claude/docs)
- [GitHub: Prompt Engineering](https://docs.github.com/en/copilot)
